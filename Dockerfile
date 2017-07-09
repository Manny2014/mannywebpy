FROM alpine:3.1

# Update
RUN apk add --update python py-pip

# Install app dependencies
RUN pip install Flask

# Bundle app source
COPY ./ app/

# Install app dependencies
RUN pip install -r app/requirements.txt

EXPOSE  8000
CMD ["python", "app/web_app.py", "-p 8000"]