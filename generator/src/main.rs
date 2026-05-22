use std::{
    env::temp_dir,
    io::{self, Write},
    path::PathBuf,
    time::Duration,
};

use handlebars::Handlebars;
use octocrab::Octocrab;
use serde::Serialize;
use sha2::{Digest, Sha256};
use uuid::Uuid;

use reqwest::Client;

struct Temporary {
    dir: PathBuf,
}

impl Temporary {
    fn new() -> Temporary {
        let mut dir = temp_dir();
        dir.push("homebrew-helper");
        std::fs::create_dir_all(&dir).expect("Dir created!");
        Temporary { dir }
    }

    async fn download_file(&self, url: &str, client: &reqwest::Client) -> String {
        let response = client
            .get(url)
            .send()
            .await
            .expect("request url should be working");
        let file_name = format!("{}", Uuid::new_v4());
        let mut file_path = self.dir.clone();
        file_path.push(file_name);
        let mut file = std::fs::File::create(&file_path).expect("We can create a file");
        let mut content = std::io::Cursor::new(response.bytes().await.expect("The file has contents"));
        std::io::copy(&mut content, &mut file).expect("Valid copy of the contents");
        file_path.to_str().expect("Can be transformed to str").to_string()
    }
}

impl Drop for Temporary {
    fn drop(&mut self) {
        let clean_result = std::fs::remove_dir_all(&self.dir);
        println!("{:?}", clean_result);
    }
}

pub fn get_hash(path: &str) -> String {
    let file_content = std::fs::read(path).expect("Failed to read file content");
    let mut hasher = Sha256::new();
    hasher.update(&file_content);
    format!("{:x}", hasher.finalize())
}

#[derive(Debug, Serialize)]
struct ArtifactInfo {
    url: String,
    sha256: String,
    target: String,
}

#[derive(Debug, Serialize)]
struct FormulaContext {
    class_name: String,
    description: String,
    homepage: String,
    license: String,
    head_url: String,
    head_branch: Option<String>,
    url: Option<String>,
    sha256: Option<String>,
    build_dependencies: Option<Vec<String>>,
    dependencies: Option<Vec<String>>,
    conflicts_with_cask: Option<String>,
    install_command: Option<String>,
    generate_completions: Option<bool>,
    completion_binary: Option<String>,
    completion_args: Option<String>,
    executable_name: Option<String>,
    test_command: Option<String>,
    binary_name: Option<String>,
    artifacts: Vec<ArtifactInfo>,
}

impl FormulaContext {
    fn new_binary(
        class_name: String,
        description: String,
        homepage: String,
        license: String,
        head_url: String,
        head_branch: Option<String>,
        conflicts_with_cask: Option<String>,
        binary_name: String,
    ) -> Self {
        FormulaContext {
            class_name,
            description,
            homepage,
            license,
            head_url,
            head_branch,
            url: None,
            sha256: None,
            build_dependencies: None,
            dependencies: None,
            conflicts_with_cask,
            install_command: None,
            generate_completions: Some(true),
            completion_binary: None,
            completion_args: Some("completion".to_string()),
            executable_name: None,
            test_command: None,
            binary_name: Some(binary_name),
            artifacts: Vec::new(),
        }
    }

    fn new_source(
        class_name: String,
        description: String,
        homepage: String,
        license: String,
        head_url: String,
        head_branch: Option<String>,
        conflicts_with_cask: Option<String>,
        binary_name: String,
    ) -> Self {
        FormulaContext {
            class_name,
            description,
            homepage,
            license,
            head_url,
            head_branch,
            url: None,
            sha256: None,
            build_dependencies: Some(vec!["rust".to_string()]),
            dependencies: None,
            conflicts_with_cask,
            install_command: None,
            generate_completions: Some(true),
            completion_binary: Some("bin/\"keepass-2-file\"".to_string()),
            completion_args: Some("completion".to_string()),
            executable_name: Some("keepass-2-file".to_string()),
            test_command: Some(
                "assert_match version.to_s, shell_output(\"#{bin}/keepass-2-file --version\")"
                    .to_string(),
            ),
            binary_name: Some(binary_name),
            artifacts: Vec::new(),
        }
    }

    fn with_source_url(&mut self, url: String, sha256: String) {
        self.url = Some(url);
        self.sha256 = Some(sha256);
    }

    fn add_artifact(&mut self, url: String, sha256: String, target: String) {
        self.artifacts.push(ArtifactInfo { url, sha256, target });
    }
}

struct FormulaGenerator {
    handlebars: Handlebars<'static>,
}

impl FormulaGenerator {
    fn new() -> Self {
        let mut handlebars = Handlebars::new();
        handlebars
            .register_template_string("source-formula", include_str!("../templates/source-formula.hbs"))
            .expect("Failed to register source-formula template");
        handlebars
            .register_template_string("binary-formula", include_str!("../templates/binary-formula.hbs"))
            .expect("Failed to register binary-formula template");
        handlebars
            .register_template_string("simple-formula", include_str!("../templates/simple-formula.hbs"))
            .expect("Failed to register simple-formula template");
        FormulaGenerator { handlebars }
    }

    fn generate_source_formula(&self, ctx: &FormulaContext) -> String {
        self.handlebars
            .render("source-formula", ctx)
            .expect("Failed to render source-formula template")
    }

    fn generate_binary_formula(&self, ctx: &FormulaContext) -> String {
        self.handlebars
            .render("binary-formula", ctx)
            .expect("Failed to render binary-formula template")
    }
}

/// Authenticate with GitHub using OAuth Device Flow
async fn authenticate_with_github() -> Result<String, Box<dyn std::error::Error>> {
    println!("🔐 Authenticating with GitHub using OAuth Device Flow...\n");

    // GitHub OAuth Device Flow client ID (registered application)
    // Register at: https://github.com/settings/applications/new
    let client_id = std::env::var("GITHUB_OAUTH_CLIENT_ID")
        .unwrap_or_else(|_| "Iv1.0000000000000000".to_string()); // Placeholder

    let client = Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .build()?;

    // Step 1: Request device code
    println!("Requesting device code...");
    let device_code_response = client
        .post("https://github.com/login/device/code")
        .header("Accept", "application/json")
        .header("User-Agent", "tap-generator")
        .form(&[("client_id", &client_id)])
        .send()
        .await?;

    if !device_code_response.status().is_success() {
        return Err(format!(
            "Failed to request device code: {}",
            device_code_response.status()
        )
        .into());
    }

    let response_text = device_code_response.text().await?;
    let device_data: serde_json::Value = serde_json::from_str(&response_text)?;
    let device_code = device_data["device_code"]
        .as_str()
        .ok_or("Missing device_code")?
        .to_string();
    let user_code = device_data["user_code"]
        .as_str()
        .ok_or("Missing user_code")?
        .to_string();
    let verification_uri = device_data["verification_uri"]
        .as_str()
        .ok_or("Missing verification_uri")?
        .to_string();
    let expires_in = device_data["expires_in"].as_u64().ok_or("Missing expires_in")?;
    let interval = device_data["interval"].as_u64().ok_or("Missing interval")?;

    println!("\nTo authenticate, please:");
    println!("1. Open: {}", verification_uri);
    println!("2. Enter code: {}", user_code);
    println!("\nWaiting for authorization...");

    // Try to open the URL automatically
    let _ = open::that(&verification_uri);

    // Step 2: Poll for access token
    let start = std::time::Instant::now();
    let timeout = Duration::from_secs(expires_in);

    loop {
        if start.elapsed() > timeout {
            return Err("Device code expired. Please try again.".into());
        }

        tokio::time::sleep(Duration::from_secs(interval)).await;

        let token_response = client
            .post("https://github.com/login/oauth/access_token")
            .header("Accept", "application/json")
            .header("User-Agent", "tap-generator")
            .form(&[
                ("client_id", &client_id),
                ("device_code", &device_code),
                ("grant_type", &"urn:ietf:params:oauth:grant-type:device_code".to_string()),
            ])
            .send()
            .await?;

        let response_text = token_response.text().await?;
        let token_data: serde_json::Value = serde_json::from_str(&response_text)?;

        if let Some(error) = token_data.get("error") {
            match error.as_str() {
                Some("authorization_pending") => {
                    print!(".");
                    io::stdout().flush()?;
                    continue;
                }
                Some("slow_down") => {
                    println!("\nRate limited. Waiting longer...");
                    tokio::time::sleep(Duration::from_secs(interval + 5)).await;
                    continue;
                }
                Some("expired_token") => {
                    return Err("Device code expired. Please try again.".into());
                }
                Some("access_denied") => {
                    return Err("Access denied by user.".into());
                }
                _ => {
                    return Err(format!("Unknown error: {:?}", error).into());
                }
            }
        }

        if let Some(access_token) = token_data.get("access_token").and_then(|v| v.as_str()) {
            println!("\n\n✓ Authentication successful!");
            return Ok(access_token.to_string());
        }
    }
}

fn extract_version_from_tag(tag_name: &str) -> String {
    tag_name.trim_start_matches('v').trim_start_matches('V').to_string()
}

fn classify_artifact(filename: &str) -> Option<&str> {
    if filename.contains("aarch64-apple-darwin") {
        Some("macos-arm")
    } else if filename.contains("x86_64-apple-darwin") {
        Some("macos-intel")
    } else if filename.contains("x86_64-unknown-linux-musl")
        || filename.contains("x86_64-unknown-linux-gnu")
    {
        Some("linux-intel")
    } else if filename.contains("aarch64-unknown-linux-musl")
        || filename.contains("aarch64-unknown-linux-gnu")
    {
        Some("linux-arm")
    } else {
        None
    }
}

#[tokio::main]
async fn main() {
    let owner = "dracks";
    let repo = "keepass-2-file";

    // Authenticate with GitHub OAuth
    let access_token = match authenticate_with_github().await {
        Ok(token) => token,
        Err(e) => {
            eprintln!("\n❌ Authentication failed: {}", e);
            eprintln!("\nAlternatively, you can set GITHUB_TOKEN environment variable:");
            eprintln!("  export GITHUB_TOKEN=your_token_here");
            std::process::exit(1);
        }
    };

    // Initialize octocrab with the access token
    let octocrab = Octocrab::builder()
        .personal_token(access_token.clone())
        .build()
        .expect("Failed to build octocrab instance");

    // Create reqwest client for downloading files
    let download_client = reqwest::Client::builder()
        .default_headers({
            let mut headers = reqwest::header::HeaderMap::new();
            headers.insert(
                reqwest::header::AUTHORIZATION,
                reqwest::header::HeaderValue::from_str(&format!("Bearer {}", access_token))
                    .expect("Invalid header value"),
            );
            headers.insert(
                reqwest::header::USER_AGENT,
                reqwest::header::HeaderValue::from_str("tap-generator").expect("Invalid header value"),
            );
            headers
        })
        .redirect(reqwest::redirect::Policy::limited(10))
        .build()
        .expect("Failed to build download client");

    println!("\nFetching latest release for {}/{}...", owner, repo);
    let release = octocrab
        .repos(owner, repo)
        .releases()
        .get_latest()
        .await
        .expect("There is a latest version");

    let version = extract_version_from_tag(&release.tag_name);
    println!("Latest version: {}", version);

    let temp = Temporary::new();
    let generator = FormulaGenerator::new();

    let mut binary_ctx = FormulaContext::new_binary(
        "Keepass2FileBin".to_string(),
        "Tool to generate environment files using secrets from a keepass file".to_string(),
        "https://github.com/Dracks/keepass-2-file".to_string(),
        "GPL-3.0-or-later".to_string(),
        "https://github.com/Dracks/keepass-2-file.git".to_string(),
        Some("main".to_string()),
        Some("keepass-2-file".to_string()),
        "keepass-2-file".to_string(),
    );

    let mut source_ctx = FormulaContext::new_source(
        "Keepass2File".to_string(),
        "Tool to generate environment files using secrets from a keepass file".to_string(),
        "https://github.com/Dracks/keepass-2-file".to_string(),
        "GPL-3.0-or-later".to_string(),
        "https://github.com/Dracks/keepass-2-file.git".to_string(),
        Some("main".to_string()),
        Some("keepass-2-file".to_string()),
        "keepass-2-file".to_string(),
    );

    let tarball_url = format!(
        "https://github.com/{}/{}/archive/refs/tags/{}.tar.gz",
        owner, repo, release.tag_name
    );
    println!("Downloading source tarball: {}", tarball_url);
    let file_path = temp.download_file(&tarball_url, &download_client).await;
    let sha256 = get_hash(&file_path);
    println!("Source tarball SHA256: {}", sha256);
    source_ctx.with_source_url(tarball_url.clone(), sha256);

    println!("\nProcessing {} assets...", release.assets.len());
    for artifact in &release.assets {
        let url = artifact.browser_download_url.as_str();
        let filename = url.split('/').last().unwrap_or("");

        if let Some(target) = classify_artifact(filename) {
            println!("Downloading artifact for {}: {}", target, filename);
            let file_path = temp.download_file(url, &download_client).await;
            let sha256 = get_hash(&file_path);
            println!("SHA256: {}", sha256);

            binary_ctx.add_artifact(url.to_string(), sha256, target.to_string());
        } else {
            println!("Skipping unrecognized artifact: {}", filename);
        }
    }

    println!("\n=== Generated Source Formula ===");
    println!("{}", generator.generate_source_formula(&source_ctx));

    println!("\n=== Generated Binary Formula ===");
    println!("{}", generator.generate_binary_formula(&binary_ctx));

    println!("\n=== Formula Context Summary ===");
    println!("Version: {}", version);
    println!("Source URL: {}", source_ctx.url.as_ref().unwrap());
    println!("Source SHA256: {}", source_ctx.sha256.as_ref().unwrap());
    println!("Binary artifacts: {}", binary_ctx.artifacts.len());
    for artifact in &binary_ctx.artifacts {
        println!("  - {}: {}", artifact.target, artifact.url);
    }
}
