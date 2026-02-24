from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
from playwright.async_api import async_playwright
import os

app = FastAPI()

PDF_INTERNAL_SECRET = os.getenv("PDF_INTERNAL_SECRET")


class RenderRequest(BaseModel):
    url: str
    pdf_secret: str


@app.post("/render")
async def render_pdf(payload: RenderRequest):

    # 🔐 Vérification du secret
    if not PDF_INTERNAL_SECRET or payload.pdf_secret != PDF_INTERNAL_SECRET:
        raise HTTPException(status_code=403, detail="Forbidden")

    async with async_playwright() as p:
        browser = await p.chromium.launch(
            args=["--no-sandbox"]
        )

        context = await browser.new_context()

        # 👇 Injecte header vers le frontend
        await context.set_extra_http_headers({
            "x-pdf-internal-secret": payload.pdf_secret
        })

        page = await context.new_page()

        await page.goto(payload.url, wait_until="networkidle")

        pdf_bytes = await page.pdf(
            format="A4",
            print_background=True
        )

        await browser.close()

    return Response(
        content=pdf_bytes,
        media_type="application/pdf"
    )