# Stage 1: Build Stage
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install 

COPY . .

RUN yarn build     

# Stage 2: Production Stage
FROM node:22-alpine

RUN addgroup -S appgroup && adduser -S -G appgroup appuser

WORKDIR /app

RUN yarn global add serve

COPY --from=builder /app/build ./build

RUN chown -R appuser:appgroup /app

EXPOSE 3000

USER appuser

CMD ["serve", "-s", "build", "-l", "3000"]