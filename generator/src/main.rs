use std::{env::{self, temp_dir}, io::Cursor, path::{ PathBuf}};

use sha2::{Sha256, Digest};
use reqwest::{self, header::{HeaderMap, HeaderValue, AUTHORIZATION, USER_AGENT}, redirect::Policy};
use uuid::Uuid;

struct Temporary {
    dir: PathBuf
}


impl Temporary {
    fn new() -> Temporary {
        let mut dir = temp_dir();
        dir.push("homebrew-helper");
        std::fs::create_dir_all(&dir).expect("Dir created!");
        Temporary { dir }
    }

    async fn download_file(&self, url: &String) -> String {
        let auth_token = env::var("GITHUB_TOKEN").expect("GITHUB_TOKEN must be set");
        let authorization = format!("Bearer {}", auth_token);
        let mut headers = HeaderMap::new();
        headers.insert(
               AUTHORIZATION,
               HeaderValue::from_str(&authorization).expect("Invalid header value"),
           );
        headers.insert(USER_AGENT, HeaderValue::from_str("auto-generator").expect("Invalid header value"));
        let client = reqwest::Client::builder().redirect(Policy::limited(10)).build().expect("Building client");
        let response = client.get(url).headers(headers).send().await.expect("request url should be working");
        let file_name = format!("{}", Uuid::new_v4());
        let mut file_path = self.dir.clone();
        file_path.push(file_name);
        let mut file = std::fs::File::create(&file_path).expect("We can create a file");
        let mut content =  Cursor::new(response.bytes().await.expect("The file has contents"));
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

/*
async fn get_hash_from_url(url: &str) -> String {

    let file_content = response.bytes().await.expect("It has the contents of the file");

    let mut hasher = Sha256::new();

    // Update hasher with file contents
    hasher.update(&file_content);

   format!("{:x}", hasher.finalize())
}*/

pub fn get_hash(path: &String) -> String{
    // Read file contents for hashing
    let file_content = std::fs::read(&path).expect("Failed to read file content");

    let mut hasher = Sha256::new();

    // Update hasher with file contents
    hasher.update(&file_content);

    format!("{:x}", hasher.finalize())
}

#[tokio::main]
async fn main() {
    //let github_token = env::var("GITHUB_TOKEN").expect("GITHUB_TOKEN must be set");
    let owner = "dracks";
    let repo = "keepass-2-file";

    //let octocrab = Octocrab::builder().personal_token(github_token).build()?;
    let octocrab = octocrab::instance();
    let repo = octocrab.repos(owner, repo);

    let release = repo.releases().get_latest().await.expect("There is a latest version");

    let artifacts = release.assets;
    let temp = Temporary::new();

    if let Some(url) = release.tarball_url {
        let file_str = temp.download_file(&url.as_str().to_string()).await;

        println!("{}: {}", url, get_hash(&file_str));

    }

    for artifact in artifacts {
        let url = artifact.browser_download_url;

        let file_str = temp.download_file(&url.as_str().to_string()).await;

       println!("{}: {}", url,  get_hash(&file_str));

    }
}
