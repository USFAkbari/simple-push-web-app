FROM node:18-alpine AS deps

WORKDIR /app

# Install production dependencies strictly according to the lockfile
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV=dev
ENV PORT=8081
ENV ACCESS_CONTROL=*

# Create a non-root user for the runtime container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only the files required to run the API
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY server.js ./server.js
COPY api ./api

USER appuser

EXPOSE 8081

CMD ["node", "server.js"]

