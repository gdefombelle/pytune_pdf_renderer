import uvicorn


def run_uvicorn():
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8011,
        reload=False,
    )


if __name__ == "__main__":
    run_uvicorn()