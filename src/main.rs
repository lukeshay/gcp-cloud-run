use actix_web::{get, middleware, post, web, App, HttpResponse, HttpServer};
use serde::{Deserialize, Serialize};
use std::env;

const HOST: &str = "0.0.0.0";

#[derive(Debug, Serialize, Deserialize)]
struct PubSubMessage {
    data: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct PubSubMessageData {
    name: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct HealthResponse {
    healthy: bool,
}

#[post("/")]
async fn index_post() -> HttpResponse {
    HttpResponse::Ok().json(HealthResponse { healthy: true })
}

#[get("/")]
async fn index_get() -> HttpResponse {
    HttpResponse::Ok().json(HealthResponse { healthy: true })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let default_port = 8080;

    let port_key = "PORT";

    let port = match env::var(port_key) {
        Ok(val) => match val.parse::<u16>() {
            Ok(port) => port,
            Err(_) => {
                log::info!(
                    "the port number \"{}\" is invalid. default port will be used.",
                    val
                );
                default_port
            }
        },
        Err(_) => {
            log::info!(
                "\"{}\" is not defined in environment variables. default port will be used.",
                port_key
            );
            default_port
        }
    };

    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    log::info!("starting HTTP server at http://{}:{}", HOST, port);

    HttpServer::new(|| {
        App::new()
            .wrap(middleware::Logger::default())
            .app_data(web::JsonConfig::default().limit(4096))
            .service(index_post)
            .service(index_get)
    })
    .bind((HOST, port))?
    .run()
    .await
}
