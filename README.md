# Apache Ambari Download Site

This is the official repository for the Apache Ambari Community Download Site. The site provides easy access to Apache Ambari and Apache Bigtop packages for Rocky Linux 8 and 9.

## Features

- Multi-language support (12 languages)
- RPM package downloads for Ambari and Bigtop
- MD5 checksum verification
- Local repository creation guide
- Responsive design

## Project Structure

```
ambari-download-site/
├── src/
│   ├── css/
│   │   └── styles.css
│   ├── js/
│   │   └── main.js
│   ├── translations/
│   │   ├── en.json
│   │   ├── zh-CN.json
│   │   └── ...
│   └── index.html
├── scripts/
│   ├── deploy.sh
│   └── update_translations.sh
└── docs/
    └── maintenance.md
```

## Setup

1. Clone the repository:
   ```bash
   git clone git@github.com:JiaLiangC/ambari-download-site.git
   cd ambari-download-site
   ```

2. Configure your web server:
   ```bash
   # For nginx
   sudo ln -s /path/to/ambari-download-site/src /var/www/html/download
   ```

## Deployment

The site can be deployed using the automated deployment script:

```bash
./scripts/deploy.sh
```

## Development

To start development:

1. Make changes in the `src` directory
2. Test locally
3. Commit changes
4. Push to main branch (deployment will happen automatically)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Apache License 2.0 