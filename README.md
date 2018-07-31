# message-transformation---ballerina
There are different ways of message transformation methods in EIP (Enterprise Integration Patterns). In this guide, we are focusing on *content filter*, *claim check* and *content enricher* message transformation methods between services using an example scenario.

> This guide describes implementing three message trasformation patterns using Ballerina programming language as simple steps.

The following are the sections available in this guide.

- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Implementation](#implementation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Observability](#observability)

## What you’ll build
When it comes to the data communication, the major challenge is formats of storage mechanisms vary among the systems. 

![alt text](images/messagetrasformation.png)

Also the message producers and consumers uses different techniques according to their requirement. So message transformation play important role to coupling those message producers and the message consumers. 
Not only that, the performance impact while message transformation is also important fact in the real world. Here we discuss about main three message transformation patterns in Enterprise Integration as content filter, content enricher and claim check.

### Content filter
The content filter EIP (Enterprise Integration Pattern) important when we need to manage large message in order to get few data from it. It removes unimportant data items from a message and leaves only the important ones. In addition to removing data elements, Content Filter can be used to simplify a message structure.

![alt text](images/contentfilter.png)

### Content enricher
The Content Enricher EIP facilitates communication with another system if the message originator does not have all the required data items available. It accesses an external data source to augment a message with missing information.


### Claim check
The Claim Check EIP reduces the data volume of messages sent across a system without sacrificing information content. It stores the entire message at the initial stage of a sequence of processing steps, and it extracts only the parts required by the following steps. Once processing is completed, it retrieves the stored message and performs any operations. This pattern ensures better performance, since large chunks of unwanted data are reduced to lightweight bits before being processed.
