fn main() {
    println!("Rust Flake!");
    println!("Git Version: {}", env!("GIT_VERSION"));

    println!("Version: {}", env!("CARGO_PKG_VERSION"));
}
