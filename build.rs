fn main() {
    println!("cargo:rustc-link-search=testing.lib");
    println!("cargo:rustc-link-lib=testing")
}