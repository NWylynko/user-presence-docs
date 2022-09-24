FROM nwylynko/bun:0.1.13-alpine as deps

WORKDIR /app

COPY ./package.json ./bun.lockb ./

RUN bun install

# Use a larger node image to do the build for native deps (e.g., gcc, python)
FROM node:16.17.0 as builder

# Reduce npm log spam and colour during install within Docker
ENV NPM_CONFIG_LOGLEVEL=warn
ENV NPM_CONFIG_COLOR=false

# copy in dependencies
COPY --chown=node:node --from=deps /app/node_modules /app/node_modules

# We'll run the app as the `node` user, so put it in their home directory
WORKDIR /app
# Copy the source code over
COPY . /app

# Build the Docusaurus app
RUN yarn build

# Use a stable nginx image
FROM nginx:stable-alpine as deploy

WORKDIR /app

# Copy what we've installed/built from production
COPY --from=builder /app/build /usr/share/nginx/html/