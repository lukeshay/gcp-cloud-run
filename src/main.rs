use actix_web::{middleware, post, web, App, HttpResponse, HttpServer};
use serde::{Deserialize, Serialize};

const HOST: &str = "127.0.0.1";
const PORT: u16 = 8080;

#[derive(Debug, Serialize, Deserialize)]
struct PubSubMessage {
    data: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct PubSubMessageData {
    name: String,
}

#[post("/")]
async fn index(message: web::Json<PubSubMessage>) -> HttpResponse {
    log::info!("model: {:?}", &message);
    HttpResponse::Ok().json(message.0) // <- send response
}

#[actix_web::main] // or #[tokio::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    log::info!("starting HTTP server at http://{}:{}", HOST, PORT);

    HttpServer::new(|| {
        App::new()
            .wrap(middleware::Logger::default())
            .app_data(web::JsonConfig::default().limit(4096))
            .service(index)
    })
    .bind((HOST, PORT))?
    .run()
    .await
}
