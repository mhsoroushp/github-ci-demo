# github-ci-demo

A simple Express.js web server built with TypeScript.

## Features

- Express.js web server
- TypeScript support
- Basic REST API endpoints
- Type-safe request/response handling

## Getting Started

### Installation

```bash
npm install
```

### Development

Run the server in development mode:

```bash
npm run dev
```

The server will start at `http://localhost:3000`

### Build

Compile TypeScript to JavaScript:

```bash
npm run build
```

### Production

Run the compiled server:

```bash
npm start
```

## API Endpoints

- `GET /` - Welcome message
- `GET /api/hello?name=YourName` - Personalized greeting
- `GET /api/status` - Server status check

## Project Structure

```
├── src/
│   └── index.ts      # Main server file
├── dist/             # Compiled JavaScript (generated)
├── package.json
├── tsconfig.json
└── README.md
```
