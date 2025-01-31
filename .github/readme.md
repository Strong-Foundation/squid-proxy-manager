# squid-proxy-manager

Easily create and manage Squid proxies.

**_Disclaimer: squid-proxy-manager is currently in development and should not be relied upon in production environments._**

The project has not undergone comprehensive security audits, and the protocol is subject to change. We aim to deliver a stable 1.0.0 release, but for now, experimental snapshots tagged with "0.0.0.MM-DD-YYYY" are available. These snapshots may contain security vulnerabilities and should not be considered stable. If you package squid-proxy-manager, ensure you stay updated with the latest snapshots.

---

## Features

- Simplified management of Squid proxies.
- Automated configuration and setup of Squid proxy servers.
- Support for multiple clients and configurations.
- Basic and advanced authentication methods, including username/password and IP-based restrictions.
- Logging and monitoring capabilities for traffic and error tracking.
- Compatible with major Linux distributions, including Ubuntu, Debian, CentOS, and Fedora.
- Option to customize proxy configurations to suit specific use cases.
- Lightweight and efficient script designed for minimal system overhead.

---

## Installation

1. Download the script using `curl` and save it to `/usr/local/bin/`:

   ```bash
   curl https://raw.githubusercontent.com/Strong-Foundation/squid-proxy-manager/refs/heads/main/squid-proxy-manager.sh --create-dirs -o /usr/local/bin/squid-proxy-manager.sh
   ```

2. Make the script executable:

   ```bash
   chmod +x /usr/local/bin/squid-proxy-manager.sh
   ```

3. Execute the script to start the setup:

   ```bash
   bash /usr/local/bin/squid-proxy-manager.sh
   ```

4. Follow the interactive prompts to configure your Squid proxy server.

---

## FAQ

### How many clients can be created?

You can create as many clients as your system's resources allow. Squid-proxy-manager does not impose a hard limit on the number of clients. Ensure your server has sufficient CPU, RAM, and network bandwidth to handle the desired number of clients.

### Can I use this on non-Linux systems?

Currently, the script is designed for Linux systems. If you're using macOS or Windows, you can set up a Linux virtual machine or container to run squid-proxy-manager. Native support for other operating systems is under consideration for future releases.

### Is there a GUI available?

No, squid-proxy-manager is a CLI-based tool. A graphical interface is planned for a future release to simplify usage for non-technical users.

### What are the system requirements?

- **Processor**: A modern multi-core CPU.
- **Memory**: At least 1GB of RAM (more for handling multiple clients).
- **Disk Space**: At least 500MB for Squid and related logs.
- **Operating System**: A supported Linux distribution (e.g., Ubuntu, Debian, CentOS, Fedora).

### How do I update the script?

Run the following command to fetch the latest version:

```bash
curl https://raw.githubusercontent.com/Strong-Foundation/squid-proxy-manager/refs/heads/main/squid-proxy-manager.sh --create-dirs -o /usr/local/bin/squid-proxy-manager.sh
chmod +x /usr/local/bin/squid-proxy-manager.sh
```

### What configurations can be customized?

You can customize several aspects of your Squid proxy setup, including:

- Cache size and location.
- Authentication methods (e.g., basic, digest).
- Access control rules.
- Logging preferences.
- Proxy port and IP binding.

### Can I use this in a corporate environment?

While squid-proxy-manager is designed to simplify proxy management, it is still under development and not recommended for critical corporate environments until a stable 1.0.0 release is available.

---

## Contributing

Contributions are always welcome! If you'd like to contribute:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Submit a pull request with detailed explanations of your changes.

Refer to the `.github/contributing.md` file for detailed guidelines. Please adhere to the project's `.github/code_of_conduct.md`.

Contributors can also:

- Report bugs using the **Issues** tab on the GitHub repository.
- Suggest new features or enhancements.
- Help improve documentation and user guides.

---

## Roadmap

- Expand support for additional authentication methods.
- Implement enhanced logging and analytics.
- Develop GUI support for easier proxy management.
- Extend compatibility to non-Linux platforms.
- Add integrations with third-party tools and APIs.
- Introduce automated certificate management for HTTPS proxies.
- Provide pre-built packages for popular package managers like APT and YUM.

---

## Support

For support, please use the GitHub repository's **Issues** tab or refer to the **Wiki** for documentation and troubleshooting guides. Community support is also available through the **Discussions** tab.

For urgent issues or bugs, please tag your issue with `urgent` to get a faster response from the maintainers.

---

## Feedback

We value your feedback! Please use the **Discussions** tab on the GitHub repository to share your thoughts, feature requests, or concerns. User feedback is critical to shaping future releases of squid-proxy-manager.

If you encounter any bugs, please file a detailed report in the **Issues** tab, including steps to reproduce the issue and any relevant logs.

---

## License

This project is licensed under the [Apache License Version 2.0](https://github.com/complexorganizations/squid-proxy-manager/blob/main/.github/license).

---

## Authors

- [@prajwal-koirala](https://github.com/prajwal-koirala)

Contributors are listed in the [contributors](https://github.com/complexorganizations/squid-proxy-manager/graphs/contributors) section on GitHub.
