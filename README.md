# HTTPie Request Manager

A powerful shell script that enhances HTTPie with request management capabilities, allowing you to save, organize, and reuse HTTP requests with an interactive file picker.

## Features

- **Automatic Request Saving**: Every HTTPie command automatically saves to timestamped `.http` files
- **Interactive File Browser**: Use `http list` to browse saved requests with fuzzy search (fzf)
- **File Preview**: Preview request content with syntax highlighting using bat
- **Quick Edit**: Edit requests directly from the picker (Ctrl+E)
- **Easy Cleanup**: Delete unwanted requests with Ctrl+X
- **Request Replay**: Execute saved `.http` files as HTTPie commands
- **Smart Parsing**: Automatically parses HTTP request format and converts to HTTPie arguments
- **HTTPS Support**: Both `http` and `https` commands are supported

## Installation

### Prerequisites

Make sure you have the following tools installed:

```bash
brew install httpie fzf bat
```

### Plugin Installation

Create a new directory in `$ZSH_CUSTOM/plugins` called `zsh-httpie-request-manager` and clone this repo into that directory.
```bash
git clone https://github.com/rokartur/zsh-httpie-request-manager.git $ZSH_CUSTOM/plugins/zsh-httpie-request-manager
```

## Usage

### Basic HTTPie Commands (with auto-save)
```bash
# Make a GET request (automatically saved)
http GET https://api.github.com/users/octocat

# POST with JSON data (automatically saved)
http POST https://httpbin.org/post name=John age:=30

# HTTPS requests work the same way
https GET api.github.com/users/octocat

# All your regular HTTPie commands work and get saved automatically!
```

### Browse and Reuse Saved Requests
```bash
# Launch interactive request browser
http list

# In the browser:
# - Use arrow keys or type to search
# - Press Enter to execute selected request
# - Ctrl+E to edit the request file with vim
# - Ctrl+X to delete the request file
```

### Execute Saved Request Files
```bash
# Run a specific saved request
http /path/to/saved/request.http

# Add additional arguments
http /path/to/saved/request.http --verbose --timeout=30
```

## File Organization

Saved requests are stored in `~/.httpie/requests/` with timestamps:
```
~/.httpie/requests/
├── 2025_01_15_at_14_30_22.http
├── 2025_01_15_at_15_45_10.http
└── 2025_01_15_at_16_20_05.http
```

Each `.http` file contains the complete HTTP request in standard format:
```http
GET /users/octocat HTTP/1.1
Host: api.github.com
User-Agent: HTTPie/3.2.0
Accept: application/json

```

## Contributing

We welcome contributions! Here are some ways you can help:

### Report Issues
- Found a bug? [Open an issue](https://github.com/rokartur/httpie-request-manager/issues)
- Request parsing not working for your use case? Let us know!

### Development
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly with different HTTPie commands
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [HTTPie](https://httpie.io/) - HTTP client
- [fzf](https://github.com/junegunn/fzf) - fuzzy finder
- [bat](https://github.com/sharkdp/bat) - file viewer with syntax highlighting

---

**Star ⭐ this repo if you**
