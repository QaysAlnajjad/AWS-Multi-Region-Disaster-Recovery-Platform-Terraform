from fastapi import FastAPI
from pydantic import BaseModel

from context_builder import build_context
from bedrock_client import ask_ai



app = FastAPI(
    title="AI Infrastructure Reviewer"
)



class ReviewRequest(BaseModel):

    terraform_plan: str

    security_results: str



@app.post("/review")
def review(request: ReviewRequest):


    context = build_context(

        request.terraform_plan,

        request.security_results

    )


    result = ask_ai(context)



    return {

        "review": result

    }