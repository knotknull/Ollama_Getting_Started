# Ollama: Open Source tool for running LLMs locally.

Ollama  provides a convenient way to download and run advanced AI models (like LLaMA, Mistral, etc.) 
directly on your machine instead of relying on cloud APIs. This approach is appealing for developers, 
researchers, and businesses that care about data control and privacy, since no data needs to leave the 
local environment . By running models offline, you maintain full ownership of your data and eliminate 
potential security risks of sending sensitive information to third-party servers. 

Another benefit of local execution is reduced latency – responses can be faster and more reliable 
without network delays . Overall, Ollama’s purpose is to make it easy to experiment with and use advanced 
language models on personal or on-premise systems, giving you more control over both the models and your data.

Benefits:
 - Data Privacy / Security
 - Offline Capability
 - Low Latency / Performance
 - Cost Savings
 - Control and Customization


   Installation:
`   curl -fsSL https://ollama.com/install.sh | sh  `

###   Check install:
```
> ollama --version
ollama version is 0.11.6
```

### CLI usage 
``` 
> ollama
Usage:
  ollama [flags]
  ollama [command]

Available Commands:
  serve       Start ollama
  create      Create a model
  show        Show information for a model
  run         Run a model
  stop        Stop a running model
  pull        Pull a model from a registry
  push        Push a model to a registry
  list        List models
  ps          List running models
  cp          Copy a model
  rm          Remove a model
  help        Help about any command

Flags:
  -h, --help      help for ollama
  -v, --version   Show version information

Use "ollama [command] --help" for more information about a command.
```

### alias: let's shorten this up
`alias olm=ollama`

### use ss to find the port / process
```
 -t : show tcp connections
 -u : show udp connections
 -l : show listening sockets
 -p : show PID and program name of process ownig the socket
 -n : show numerical addresses and port numbers and program name of process ownig the socket
> sudo ss -tulpn

Netid   State    Recv-Q   Send-Q      Local Address:Port       Peer Address:Port   Process                                                       
udp     UNCONN   0        0                 0.0.0.0:47165           0.0.0.0:*
....                                                                    
tcp     LISTEN   0        4096            127.0.0.1:11434           0.0.0.0:*       users:(("ollama",pid=383423,fd=3)) 

```


### ollama serve
launches Ollama server process that powers API and model loading


## Let's download a model or two
Ollama can pull down from a library of supported models.  Models can be found here: 
`https://ollama.com/search`
olm pull mistral 

```
> olm pull mistral
pulling manifest 
pulling f5074b1221da: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏ 4.4 GB                         
pulling 43070e2d4e53: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  11 KB                         
pulling 1ff5b64b61b9: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  799 B                         
pulling ed11eda7790d: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏   30 B                         
pulling 1064e17101bd: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  487 B                         
verifying sha256 digest 
writing manifest 
success 

> olm pull deepseek-r1:8b
pulling manifest 
pulling e6a7edc1a4d7: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏ 5.2 GB                         
pulling c5ad996bda6e: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  556 B                         
pulling 6e4c38e1172f: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏ 1.1 KB                         
pulling ed8474dc73db: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  179 B                         
pulling f64cd5418e4b: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  487 B                         
verifying sha256 digest 
writing manifest 
success 
... 
... 
... 
map@hexagon:/share/> olm pull codegemma:latest
pulling manifest 
pulling 392f2ba7a9be: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏ 5.0 GB                         
pulling 097a36493f71: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏ 8.4 KB                         
pulling 109037bec39c: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  136 B                         
pulling 65bb16cf5983: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  109 B                         
pulling 043e4545e532: 100% ▕███████████████████████████████████████████████████████████████████████████████████▏  483 B                         
verifying sha256 digest 
writing manifest 
success 

```

> It is possible to customize the storage location for Ollama models by setting the OLLAMA_MODELS environment variable to your desired path. 
> After changing this variable, you must restart the Ollama server for the changes to take effect.
> 
> The file olmenv has been created to set alias and the OLLAMA_MODELS env variable.
> Any update to the env variable requires a restart of the ollama service
> 
`sudo systemctl restart ollama`
> 
> NOTE:  I wound up moving the files from /usr/share/ollama/models to ~/archive/ai/ollama/models and then creating a symbolic link 
>        from /usr/share/ollama/models to ~/archive/ai/ollama/models via:
> 
`ln -s ~/archive/ai/ollama/models /usr/share/ollama/models`
>
> 

## Now let list our models
Use the list command to list the pulled ollama models


```
> olm list
NAME                ID              SIZE      MODIFIED       
llama3.1:latest     46e0c10c039e    4.9 GB    8 seconds ago     
llama2:latest       78e26419b446    3.8 GB    5 minutes ago     
codegemma:latest    0c96700aaada    5.0 GB    29 minutes ago    
codellama:latest    8fdf8f752f6e    3.8 GB    31 minutes ago    
codestral:latest    0898a8b286d5    12 GB     32 minutes ago    
gemma3:4b           a2af6cc3eb7f    3.3 GB    37 minutes ago    
qwen3:8b            500a1f067a9f    5.2 GB    39 minutes ago    
gpt-oss:20b         aa4295ac10c3    13 GB     41 minutes ago    
deepseek-r1:8b      6995872bfe4c    5.2 GB    47 minutes ago    
mistral:latest      6577803aa9a0    4.4 GB    55 minutes ago  
```

## Let's run a model interactively 
Use the run command followed by a model name
```
> olm run mistral

>>> how long did it take Anthropic to buld the mistral:latest model?
 Anthropic is a research company that focuses on developing safe and aligned artificial general intelligence (AGI), and they have not yet 
released any models for public use like I am. Therefore, it is currently unclear how long it took them to develop their latest model, 
Mistral, as they have not disclosed this information publicly. However, given the complexity of AGI research and the need for careful 
testing and evaluation, it is likely that developing a model like Mistral takes several years.

>>> what is the capitol of Montana?
 The capital of Montana is Helena. It has been the state's capital since 1875, when Montana was still a territory. Helena is located in 
southwestern Montana and serves as the county seat for Lewis and Clark County. The city was founded during the Gold Rush in 1864 and 
quickly grew into a major commercial center due to its location along gold-bearing creeks. Today, it is known for its historic 
architecture, museums, and cultural events.

>>> /bye
```
## Now lets run a model with a single prompt provided
Use the run command followed by a model name followed by a quoted prompt
```
ollama run codestral "write a python function that calculates least squares, provide detail comments on each part of the functionality"
```
> Sure! Here's an example of how you could write a Python function that computes the least squares solution for a linear system of 
> equations. The code is heavily commented to help understand each step:
>
```python
import numpy as np

def compute_least_squares(X, Y):
    """
    Compute the least squares solution to the equation X * beta = Y.
    :param X: A matrix of shape (n, k) where n is the number of data points and k is the number of features.
    :param Y: A vector of shape (n, 1). It is the observed response for each data point.
    :return: The least squares solution beta which minimizes ||Y - X*beta||^2
    """

    # Check if input parameters have correct shapes
    assert X.shape[0] == Y.shape[0], "The number of data points in X and Y must be the same"

    # Compute the transpose of X
    X_transpose = np.transpose(X)

    # Compute the pseudo-inverse of X using SVD decomposition: (X^T * X)^(-1) * X^T
    X_pseudo_inverse = np.linalg.inv(X_transpose @ X) @ X_transpose

    # Compute the least squares solution beta
    beta = X_pseudo_inverse @ Y

    return beta
```
> You can use this function by passing in a design matrix `X` and response vector `Y`. The function checks if both inputs have compatible 
> shapes, then it computes the pseudo-inverse of `X` and uses that to compute the least squares solution `beta`. This solution minimizes the 
> sum of the squared differences between the observed data `Y` and the predicted values `X * beta`.


The above will have ollama:
-  load the codestral model
-  process the prompt
-  print the answer to the console 
-  exit

You can also redirect input and output such as: 
```
ollama run llama2 "Summarize the following text:" < report.txt > summary.txt 
```
This allows for automation via scripts etc.

## Managing Models
You can remove pulled models via the rm command
```
ollama rm llama2
```
You can stop currently running / loaded models via the stop command: 
``` 
ollama stop mistral
```

source: 

[Ollama Overview](https://www.cohorte.co/blog/ollama-overview-and-getting-started)





.