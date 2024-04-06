from flask import Flask, request, jsonify, render_template

import speech_backend
import debate_backend
import writing_backend
import random

app = Flask(__name__)


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/about-us")
def about_us():
    return render_template("about-us.html")


@app.route("/get-started")
def get_started():
    return render_template("get-started.html")


@app.route("/speech")
def speech():
    # sample_text = generate_sample_text()
    num = random.randrange(20)
    with open(f"static/cache/text{num}.txt") as file:
        sample_text = file.read()

    response = speech_backend.generate_response()
    return render_template(
        "speech.html", num=str(num), sample_text=sample_text, response=response
    )


@app.route("/debate")
def debate():
    return render_template("debate.html")


@app.route("/get_response/<user_input>")
def get_response(user_input):
    response = debate_backend.generate_response(user_input)
    return response


@app.route("/writing")
def writing():
    return render_template("writing.html")


@app.route("/writing_get_response/<user_input>")
def writing_get_response(user_input):
    response = writing_backend.generate_response(user_input)
    return response


if __name__ == "__main__":
    app.run(debug=True)
