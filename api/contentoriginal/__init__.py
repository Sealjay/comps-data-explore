import logging
import mimetypes
import azure.functions as func


def main(req: func.HttpRequest, obj: func.InputStream) -> func.HttpResponse:
    path = req.route_params.get("id")
    logging.info(f"Python HTTP-triggered function processed: {path}")

    if obj is None:
        return func.HttpResponse("File not found", status_code=404,)

    try:
        # Get the mimetype from the file extension
        mime_type = mimetypes.guess_type(path)[0] or "application/octet-stream"
        logging.info(f"Mimetype for {path}: {mime_type}")

        # return the obj file with the correct mimetype
        return func.HttpResponse(
            obj.read(),
            mimetype=mime_type,
            status_code=200,
            headers={
                "Content-Disposition": f"inline; filename={path}",
                "Content-Type": mime_type,
            },
        )
    except Exception as e:
        logging.error(e)
        return func.HttpResponse(f"Error: {e}", status_code=500,)
