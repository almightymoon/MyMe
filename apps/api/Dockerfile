FROM node:20.18.1-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY prisma ./prisma
COPY tsconfig.json tsconfig.build.json nest-cli.json ./
COPY src ./src
RUN npx prisma generate && npm run build

FROM node:20.18.1-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apk add --no-cache wget
RUN addgroup -S memy && adduser -S memy -G memy
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY prisma ./prisma
USER memy
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD wget -qO- http://127.0.0.1:3000/api/v1/health/live || exit 1
CMD ["node", "dist/main.js"]
