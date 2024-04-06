from flask import Flask, render_template
from gemini import generate_sample_text, generate_response
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


@app.route("/medium")
def medium():
    # sample_text = generate_sample_text()
    num = random.randrange(20)
    with open(f"static/cache/text{num}.txt") as file:
        sample_text = file.read()

    response = generate_response()
    return render_template("medium.html", num=str(num), sample_text=sample_text, response=response)


if __name__ == "__main__":
    app.run(debug=True)
