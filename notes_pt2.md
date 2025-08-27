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
[LAST HERE]



*source:* 
[Ollama Part 2](https://www.cohorte.co/blog/ollama-advanced-use-cases-and-integrations)

