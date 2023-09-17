use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    // print text
    Print { text: String },
}

fn main() {
    let cli = Cli::parse();
    match &cli.command {
        Commands::Print { text } => print_text(text.to_string()),
    }
}

fn print_text(text: String) {
    println!("text: {text:?}");
}
