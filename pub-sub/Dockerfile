FROM rust:1.60.0 as build

# create a new empty shell project
RUN USER=root cargo new --bin pub-sub
WORKDIR /pub-sub

# copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm -f src/*.rs

# copy your source tree
COPY ./src ./src

# build for release
RUN rm -f ./target/release/deps/pub-sub*
RUN cargo build --release

# our final base
FROM rust:1.60.0

# copy the build artifact from the build stage
COPY --from=build /pub-sub/target/release/pub-sub .

# set the startup command to run your binary
CMD ["./pub-sub"]