# ?Ž‰ Nix Flakes Templates ?Ž‰

I created this repository as a collection of personal Nix flakes templates that I use for various projects. The main template in this repository is a Golang template with support for creating a Nix module and a Nix container. Flakes are a new way to manage Nix packages, and these templates can serve as a starting point for your own flakes projects.

## Templates

- ?’¡ [Golang Template] A template for creating a Golang project. This template includes the following features:
  - Direnv support for automatically loading environment variables when entering the project directory.
  - A Nix module for creating a systemd service to run the Golang project as a daemon.
  - Nix container which starts the systemd service automatically
  
  

## Installation

To use these templates, clone the repository and navigate to the desired template directory. Then, run the following command to create a new flake:

`nix flake init -t github:9glenda/templates`

## Usage

Instructions for using the templates go here. This can include examples of how to customize the templates for your own projects, or any other relevant information.

## Contributing

If you have any suggestions for improvements to the templates, or if you find any bugs, please open an issue or submit a pull request. I welcome all contributions!

## License

This repository is licensed under the GNU General Public License v3.0 (GPL v3). See the [LICENSE](https://chat.openai.com/LICENSE) file for more information.

I hope this helps! 
