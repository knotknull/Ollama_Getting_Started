# Ollama: Advanced Use Case and Integrations

Ollama  can be used as part of larger systems: 
 - integrating with Open WebUI sleek interface
 - utilizing LiteLLM for API unification
 - leveraging like LangChain for advanced workflows 

### Model Management
Get information about models via show command:
```
> ollama show gpt-oss:20b
  Model
    architecture        gptoss    
    parameters          20.9B     
    context length      131072    
    embedding length    2880      
    quantization        MXFP4     

  Capabilities
    completion    
    tools         
    thinking      

  Parameters
    temperature    1    

  License
    Apache License               
    Version 2.0, January 2004    
    ...  

```

### Custom Models and Fine-Tuning 
Can create new models from existing ones 
`create <new_model>
Used to fine-tune a model.  Using llama.cpp allows for lightweigh fine-tuning 
or applying delta weights to models.  Can also integrate with fine-tuning libraries 
or use low-rand adaptation (LoRA) files to specialize a model for a specific domain 
and serve via Ollama.  Ollama can serve as a **local model hub** for both pre-trained 
and custom built and fine-tuned models

### Enhanced Prompting and Memory
Using interactive mode, models have a conversation history (context length).
You can adjust context length and system prompts.  Ollama allows to its configuration
to change system-level instructions or persona for a model.  Configuration can be done
via config files (if supported by model) or via commands in the REPL (/system or similar).
Contxt window can be changed by using larger context models or setting env variables 
(i.e. OLLAMA_CONTEXT_LENGTH) when starting `ollama serve`.  **function calling / JSON output**

### Enhanced Prompting and Memory
Structured output allows you to constraing a model's output to a specific JSON schema.
Ollama will help enforce the output the to requested JSON structure.  

### Tool Usage (Function Calling)
Ollma has support for tool calling for models.  Certain models and be configured with 
tools to perform an action (web search, calculation, etc).  Ollama allows models to interact 
via function calls.  Ollama can acts as a framework for building AI agents that execute tasks.

### Multimodal Models
Ollama supports certain multimodal models (Llama 3.2 Vision).  They can handle text and 
images. Ollama isn't limited to text-only models.

### Embedding Models for RAG:
Retrieval-Augmented Generation (RAG).  Use a smaller embedding model to converte text into 
vecotr embeddings for similarity search.  Ollama has support for embeddin gmodels.  i.e. 
Can generate embeddings of documents locally and build a semantic search / FAQ system. 
*For example, you could use an Ollama-served embedding model to index a corpus of PDFs, then when a query comes, find relevant text by embeddings, and feed that into a larger LLM also hosted on Ollama.*

## Using Ollama in Production
Ollama has been designed for local dev / experimentation and the API is not meant for heavy 
production usage. BUT, can be deployed in a production workflow in the correct circumstances. 

### Single-User vs Multi-User 
High throughput and parallel requests handling are not Ollama's strong points.  
For low concurency use cases or serial batch jobs, Ollama can handle them well. 

### Resource Management
Ollma server in Production usually runs with model pre-loaded for faster responses.
Ollama *may* unload a model to free memory but this behavior can be configured. 

### Scaling
Can run multiple instances of Ollama behind a load balancer.

### Stateless API
Each API request is idependent (unless you build a conversation by resendig history).

### Deployment Environment
Ollama can be deployed to coud.  Ollama can also run in a container and ths can run in 
K8s, or Google Cloud Run or Azure Container Instances for serverless. There are tradeoffs 
where an enterprise grade serving solution (OpenLLM, Text Generation Inference) 

### Realistic use cases
 - integration into an internal company tool  
    - don't have to send data to an external source.
 - production pipeline / workflow
 - Ollama works well in small  


## Integrations with OpenWebUi, LiteLLM and others

### Open WebUI - GUI for Local LLMs
aka Ollama WebUI, open source web interface that works with local LLM backends.
Open WebUI is a Web Application that connects to Ollama API. 
Local website http://localhost:3000 
Run via docker:
```
## podman run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway \
##  -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:main
## This works for me, had something running on 3000
## NOTE: the final version uses --network=host
## 
# podman run -d \
#   --name open-webui \
#   -p 8181:8080 \
#   -v open-webui:/app/backend/data \
#   -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
#   --restart always \
#   ghcr.io/open-webui/open-webui:main

##  working: changed -p 8181:8080 to --network=host
##  This allows connectivity to Ollama @ http://127.0.0.1:11434 
##  open-webui to access all of the local models.  
podman run -d \
  --name open-webui \
  --network=host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --restart always \
  ghcr.io/open-webui/open-webui:main


## validate via:
curl http://localhost:8080


 note: I changed over to podman from docker
```

### LiteLLM: bridging APIs 
- a proxy that provides an OpenAI-compatible API on one side and translates to various 
backend calls on the other. 
- Open WebUI <-> LiteLLM <-> [Azure OpenAI, Amazon Bedrock, etc]
 
***Integrating LiteLLM***: In an Ollama + Open WebUI setup, you’d deploy LiteLLM (it can be a small server or container) configured with the routes to your desired endpoints. For instance, configure it so that requests with model name “azure/gpt4” go to Azure OpenAI, and requests with model name “ollama/llama2” go to your local Ollama. Open WebUI would then point to LiteLLM as its backend (instead of directly to Ollama). A lot of this can be orchestrated with Docker Compose: you’d have one service for Open WebUI, one for LiteLLM, and maybe one for Ollama, all networked together. In fact, a Docker Compose example from a blog shows how they linked Open WebUI and LiteLLM, setting OPENAI_API_BASE_URL to the LiteLLM service and an extra_hosts entry so that the WebUI container can find the Ollama host machine​.

The end result is a ***flexible AI stack***: Open WebUI for UI, LiteLLM for intelligent routing, and Ollama (plus possibly others) for actual model serving​. This setup means users can switch between models (local or cloud) seamlessly. For example, you might primarily use the local model to save costs, but if it fails or if you need a second opinion, you switch to a cloud model via the same interface.

### Other Frameworks and Integrations

- LangChan: due to Ollama compatability with OpenAI API, you can use LangChain to integrate it (openai.ChatCompletion)
python:
```
import openai
openai.api_base = "http://localhost:11434"  # Ollama's default API endpoint
openai.api_key = "ignored"  # Ollama doesn't require a key, but the client needs one set
response = openai.ChatCompletion.create(
    model="llama2",
    messages=[{"role": "user", "content": "Hello, world!"}]
)
print(response["choices"][0]["message"]["content"])
```
This allows complex integration with multiple local models. 

- Custom UI / Bots: Raycast, "Continue" VS Code extension

- BentoML OpenLLM:  BentoML's OpenLLM framework can serve LLMs in Production.
BentoML allows you to containerize an Ollama model easiily.  
  BentoML --> [Docker image [Ollama model]] --> deploy 

- API / SDKs :  Ollama provides Python / Javascript  
  - python : pip install ollama 
  - Node.js: Javascript SDK

- Other GUIs: Text Generation Web UI, OobaBooga UI)
  NOT: Ollama speaks a common language (OpenAI API and its own resP API )

- Cloud Integrations: Integration w/ Azure Functions / AWS Lambda-like env 
for serverless usage. 

- Workflow Managers: LangFlow, Flowise  (provides a UI to build langchain flows)
  Airflow coudld call Ollama as part of pipeline

### Code Snippet: Using Ollama with a WebUI
Code the shows integration with OpenWebUI and Ollama using Docker Compose
docker-compose.yml:
```
# docker-compose.yml
version: '3'
services:
  ollama:
    image: ollama/ollama:latest  # assume an Ollama docker image
    ports:
      - "11434:11434"
    volumes:
      - ollama-data:/root/.ollama  # persist models
    command: ollama serve

  webui:
    image: ghcr.io/open-webui/open-webui:main
    depends_on:
      - ollama
    ports:
      - "3000:8080"
    environment:
      OPENAI_API_BASE_URL: "http://ollama:11434"    # point WebUI to Ollama service
      OPENAI_API_KEY: "not_used_but_required"
      WEBUI_AUTH: "false"  # disable auth for simplicity
    extra_hosts:
      - "ollama:127.0.0.1"  # ensure the container can resolve the name (if needed)

```
Two services: ollama and webui. The WebUI is configured to talk to the Ollama’s API. By running docker-compose up, you would get a local Ollama server and the Open WebUI all set up together. Then y

### Code Snippet: Hybrid API via LiteLLM (Integraion Example)
[LAST HERE]





*source:* 
[Ollama Part 2](https://www.cohorte.co/blog/ollama-advanced-use-cases-and-integrations)
LLava, BakLLava (text to image generation / vistion-language model)

