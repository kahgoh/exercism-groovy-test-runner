# === Build maven cache ===

FROM maven:3.9.16-eclipse-temurin-25-noble@sha256:01ef98a139ed64622c086bac54d1e167453d0f2ff68b69d00978f26d8736215c AS cache

# Ensure exercise dependencies are downloaded
WORKDIR /opt/exercise
COPY src/ src/
COPY pom.xml .
RUN mvn test dependency:go-offline -DexcludeReactor=false

# === Build runtime image ===

FROM maven:3.9.16-eclipse-temurin-25-noble@sha256:01ef98a139ed64622c086bac54d1e167453d0f2ff68b69d00978f26d8736215c
WORKDIR /opt/test-runner

RUN apk update && \
        apk add --no-cache --upgrade jq sed grep && \
        rm -rf /var/cache/apk/*

# Copy resources
COPY . .

# Copy cached dependencies
COPY --from=cache /root/.m2 /root/.m2

# Copy Maven pom.xml
COPY --from=cache /opt/exercise/pom.xml /root/pom.xml

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

