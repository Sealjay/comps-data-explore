import json
import logging
import os
import time

import azure.functions as func
import openai
from azure.identity import DefaultAzureCredential
from azure.search.documents import SearchClient

# import from the chatreadretrieveread.py file in the lib directory
from .utils.chatreadretrieveread import ChatReadRetrieveReadApproach

# Using os.environ["myAppSetting"] format so an error will be raised if unset

AZURE_SEARCH_SERVICE = os.environ["AZURE_SEARCH_SERVICE"]
AZURE_OPENAI_SERVICE = os.environ["AZURE_OPENAI_SERVICE"]

AZURE_OPENAI_GPT4_DEPLOYMENT = os.environ["AZURE_OPENAI_GPT4_DEPLOYMENT"]

AZURE_SEARCH_INDEX = os.getenv("AZURE_SEARCH_INDEX") or "gptkbindex"
KB_FIELDS_CONTENT = os.getenv("KB_FIELDS_CONTENT") or "content"
KB_FIELDS_CATEGORY = os.getenv("KB_FIELDS_CATEGORY") or "category"
KB_FIELDS_SOURCEPAGE = os.getenv("KB_FIELDS_SOURCEPAGE") or "sourcepage"

# Use the current user identity to authenticate with Azure OpenAI,
# Cognitive Search and Blob Storage (no secrets needed,
# just use 'az login' locally, and managed identity when deployed on Azure).
# If you need to use keys, use separate AzureKeyCredential instances with the
# keys for each service
# If you encounter a blocking error during a DefaultAzureCredential
# resolution, you can exclude the problematic
# credential by using a parameter (ex. exclude_shared_token_cache_credential=True)
# try:
azure_credential = DefaultAzureCredential()
# except Exception:
# azure_credential = AzureCliCredential(tenant_id=AZURE_TENANT_ID)

# Used by the OpenAI SDK
openai.api_type = "azure"
openai.api_base = f"https://{AZURE_OPENAI_SERVICE}.openai.azure.com"
openai.api_version = "2023-03-15-preview"

# Comment these two lines out if using keys, set your API key in
# the OPENAI_API_KEY environment variable instead
openai.api_type = "azure_ad"
openai_token = azure_credential.get_token(
    "https://cognitiveservices.azure.com/.default"
)
openai.api_key = openai_token.token

search_client = SearchClient(
    endpoint=f"https://{AZURE_SEARCH_SERVICE}.search.windows.net",
    index_name=AZURE_SEARCH_INDEX,
    credential=azure_credential,
)

chat_processor = ChatReadRetrieveReadApproach(
    search_client,
    AZURE_OPENAI_GPT4_DEPLOYMENT,
    KB_FIELDS_SOURCEPAGE,
    KB_FIELDS_CONTENT,
)


def ensure_openai_token():
    global openai_token
    if openai_token.expires_on < int(time.time()) - 60:
        openai_token = azure_credential.get_token(
            "https://cognitiveservices.azure.com/.default"
        )
        openai.api_key = openai_token.token


def main(req: func.HttpRequest) -> func.HttpResponse:
    """Generate a chat response from a GPT-4 model."""
    logging.info("Chat GPT response function processed a request.")

    ensure_openai_token()
    json_body = req.get_json()
    logging.info(json_body)
    try:
        r = chat_processor.run(json_body["history"], json_body["overrides"] or {})

        return func.HttpResponse(
            json.dumps(r), status_code=200, headers={"Content-Type": "application/json"}
        )
    except Exception as e:
        logging.exception("Exception in /chat")
        return func.HttpResponse(
            json.dumps({"error": str(e)}),
            status_code=500,
            headers={"Content-Type": "application/json"},
        )
