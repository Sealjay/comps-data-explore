class ChatUtils:
    def return_default_messages(prompt):
        return messages

    def setup_engine(openai, engine, messages):
        engine = openai.ChatCompletion.create(
            engine=engine,
            messages=messages,
            temperature=0.7,
            max_tokens=800,
            top_p=0.95,
            frequency_penalty=0,
            presence_penalty=0,
            stop=None,
        )
        return engine

    def return_response(message, engine, message_log=False):
        if not message_log:
            new_messages = default_messages.copy()
        else:
            new_messages = message_log.copy()
            new_messages.append({"role": "user", "content": message})
            response = setup_engine(engine, new_messages)
        return response, new_messages
