# Part 3: Ollama for AI Model Serving 

Ollama can be used as a full-fledged AI service.
Ollama as a service for AI model serving and hosting.


## Using Ollama for AI Model Serving and Hosting

Serving model akin to a webserver. ```ollama serve``` listens for API requests on 11434.
Ollama has a multiple API endpoint: 
 - **Primary API endpoint:** ``` http://localhost:11434/api/generate ```    
 takes JSON payload with model name and prompt.  
 - **OpenAI-compatible API endpoint :** ``` http://localhost:11434/v1/chat/completions```  
 send OpenAI-format request (model, messaages, etc.)    

**Model loading behavior:**
  - first time model is run it is loaded to memory 
  - subsequent requests uses model in memory
  - model unloaded from memory after idle time

**Concurrency:**
  - Ollama processes one request at a time per model
  - incoming request may have to wait.
  - ***scale via multiple instances ??***

**Remote Access:**
  - To server non-local clients will need to bind external interface
    - flat / env variable to bind to 0.0.0.0
    - run behind reverse proxy (nginx)
  - ***NOTE: Ollama has not authentication itself***

**Maintence:**
  - Server resources need to be monitored
  - CPU / GPU / Memory
  - logging

**Batching / Streaming:**
  - Ollama's "might" supprot streaiming with ```stream: true``` in request.
  - Batching not standard feature of API


## Optimization Techniques for Better Performance

**Use Appropriate Model Sizes and Quantization:**
  - Smaller models for faster results:  7B vs 70B
  - Quantize models to lower memory (some quality hit)  
  ***i.e. -q4  indicates 4-bit quanization ***

**GPU Acceleration:**
  - Ensure Ollama is using GPU
  - Load appropriate drivers and set env vars i.e. **LLAMA_ACCELERATE**
  - Monitor usage i.e. nvidia-smi:   


```
> nvidia-smi
Mon Sep  1 21:07:43 2025       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.247.01             Driver Version: 535.247.01   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce GTX 745         Off | 00000000:01:00.0  On |                  N/A |
| 27%   60C    P0              N/A /  N/A |    774MiB /  4096MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A      2370      G   /usr/lib/xorg/Xorg                          352MiB |
|    0   N/A  N/A      3035      G   cinnamon                                     85MiB |
|    0   N/A  N/A      3980      G   /usr/lib/firefox/firefox                    281MiB |
|    0   N/A  N/A     60202      G   /usr/share/code/code                         42MiB |
+---------------------------------------------------------------------------------------+
```
  - only CPU: use smaller models, consigher high CPU cores for parallel token processing


**Threads Settings:**
  - Under the hood llama.cpp can use multiple threads for faster token generation
  - Check for settings to control via flag or env vars.

**Context Lenghth and Tokens:**
  - Long prompts slow down inference
  - Limit answer size if possible
  - Set the maximum tokens i.e. ```set max_tokens```

**Keep Models in Memory:**
  - Avoid loading / reloading models
  - Keep model "warm" with occasional dummy requests
  - First load can be 10 - 30 seconds
  - If running in container: 
    - load model weights into container 
    - initialize the model on container start

**Use Ollama API Efficiently:**
  - have clients utilize streaming
  - shorter prompts, system prompts once
  - batch requests

**Scaling Out:**
  - bound to different ports
  - containerize
  - round robin load balancer (nginx, HAProxy)
  - instance per model


## Implementation Guide

**1. Start Server:**
Start server or start with nohup: 
```
ollama serve 

## OR put in the background and redirect output to ollama.log 

nohup ollama serve &> ollama.log &  
```

**2. Construct a Request:**
Use a tool like curl or Postman to initiate a request
```
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
        "model": "mistral",
        "prompt": "What is the capital of France?",
        "system": "",
        "options": {
            "temperature": 0.7,
            "max_tokens": 100
        }
      }'
```
Let’s break down this JSON:
  - "model": "mistral" specifies which model to use (it should be one you have pulled; if not, the server will try to pull it now).
  - "prompt": "What is the capital of France?" is the user prompt. We leave "system": "" empty here (that field could be used to send a system instruction, akin to setting context).
  - "options" can include generation parameters like temperature, max_tokens, top_p, etc. (The exact fields supported should match what Ollama expects; this example assumes these are valid.)


Sample of a reponse: 
```
{
  "response": "The capital of France is Paris.",
  "model": "mistral",
  "created_at": "2025-03-17T08:48:00Z"
}
```
The following is an OpenAI equivalent API served by Ollama (notice the Authorization):
```
curl -X POST http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy" \
  -d '{
        "model": "mistral",
        "messages": [
            {"role": "user", "content": "What is the capital of France?"}
        ]
      }'
```
NOTE: Authorization header used because OpenAI API requires one (Ollama ignores it)
Response format:
```
{
  "id": "cmpl-xyz123...",
  "object": "chat.completion",
  "created": 1700000000,
  "model": "mistral",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "finish_reason": "stop"
    }
  ]
}
```
This mirrors OpenAI's reposnse format, especially the choices[0].message.content


**3. Integrate into an Application :**
Example of making a request utilizing Python: 
```
import requests
import json

url = "http://localhost:11434/api/generate"
payload = {
    "model": "mistral",
    "prompt": "Tell me a joke about cats.",
    "options": {"max_tokens": 50}
}
response = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(payload))
if response.status_code == 200:
    data = response.json()
    print("Model says:", data.get("response"))
else:
    print("Error:", response.status_code, response.text)
```

**4. Enable Streaming :**
Example utilizing streaming in the response (token by token) : 
```
import openai
openai.api_base = "http://localhost:11434"
openai.api_key = "unused"
response = openai.ChatCompletion.create(
    model="mistral",
    messages=[{"role": "user", "content": "Why is the sky blue?"}],
    stream=True
)
for chunk in response:
    chunk_message = chunk['choices'][0]['delta'].get('content', '')
    print(chunk_message, end='', flush=True)
```
This prints answer as it arrives. OpenAI streaming returns 
imcremental ``delta`` objects.

**5. Optimize:**
See earlier section

**6. Scale:**
See earlier section


Below is flask-like pseudo code to get reqeust and forward to Ollama:
```
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "mistral"

@app.route('/ask', methods=['POST'])
def ask():
    user_question = request.json.get('question')
    payload = {"model": MODEL_NAME, "prompt": user_question}
    try:
        resp = requests.post(OLLAMA_URL, json=payload, timeout=30)
        data = resp.json()
        answer = data.get("response") or data.get("choices")[0]["message"]["content"]
        return jsonify({"answer": answer})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Running the Flask app (in production, use gunicorn or similar)
if __name__ == "__main__":
    app.run(port=5000)
```


## "Real-WOrls Applications of AI MOdel Serving with Ollama
 - IT Support chatbot, utilizing domain knowledge
 - Content Generation: media company serving a model to help draft article, social media posts
 - Data Analysis Assitant
 - IoT / Offline Applications: running LLM in remote locations: ships, military
 - Software Testing
 - Education / Training: provide homewor, quiz questions, etc.
 - Bridge for Tools / Agents: decouple agent logic from LLM
 - **Real World Situration:** connect Ollama to robot arm.  
 Describe task for arm to do and LLM would create step-by-step instructions.  
 Running locally meant no latency. 
 - **Real World Situration 2:** RAG: Ollama serve embedding model and chat model.
 User query first used to fetch documents documents via vector search using embedding model.
 Documents then given to chat model for answer.  


*source:* 
[Ollama Part 3](https://www.cohorte.co/blog/ollama-for-ai-model-serving)
LLava, BakLLava (text to image generation / vistion-language model)

