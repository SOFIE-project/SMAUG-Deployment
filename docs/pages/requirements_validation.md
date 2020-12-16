# SOFIE requirements validation

This page contains a step-by-step guide to executing all the marketplace interactions via the provided CLI app, with the goal of validating two SOFIE requirements. The requirements are described in [SOFIE deliverable 2.6: Federation Architecture, Final Version](https://media.voog.com/0000/0042/0957/files/SOFIE_D2.6-Federation_Architecture_final_version-2.pdf) and are:

|Req. ID|Requirement Description|Priority|Category|
|:-----:|:---------------------:|:------:|:------:|
|**RA05**|The system must provide auditability.|MUST|SECURITY|
|**RF23**|The marketplace must provide evidence once trades have MUST been completed<br> and resources have been properly delivered to the buyers.|MUST|SECURITY|

The requirements are validated by carrying out a complete marketplace interaction, from request creation to (simulated) smart locker access, and by demonstrating that all the key information is generated and immutably stored on either the marketplace or the authorization blockchain, providing auditability and evidence of trade completion.

## Simulate the marketplace interactions

To set up the test environment, follow the instructions provided in the [main documentation page](../../README.md).

With the environment up and running, take control of the marketplace CLI application by running `docker attach marketplace-agent`. When opened, a list of possible commands is shown, including changing the Ethereum account used to perform the marketplace operations, and creating requests and offers.

### Step 1: Selecting a smart locker owner account and opening a request

If needed, a different Ethereum account than the one selected by the default can be chosen. This is achievable by selecting action n. 2) and choose one of the Ethereum accounts with enough balance to cover request creation and decision costs (balance should be >= 1000000000 weis). After this, the next step is to create a new auction request. To do so, select action n. 4) and fill in the request details as asked by the CLI app. As for the locker ID, any numeric value is valid, as this is just a simulated interaction. **Take note of the ID of the request just created.**

At the end of this step, a new request is created and ready to accept offers.

### Step 2: Selecting a smart locker renter account and submitting an offer

As in step 1, a different Ethereum account can be chosen for the smart locker renter operations, although not relevant for the purpose of the requirement validation. After this optional step is performed, select action n. 5) and fill in the details of the offer to submit, by specifing the ID of the request created in step 1. **Take note of the ID of the offer just created.**

> Make sure that the offer start and end time are included in the start and end time of the request (i.e., that the time range of the access being requested is included in the time range specified in the request), otherwise the offer creation will fail. Furthermore, make sure that the total price specified in the offer is enough to cover the total costs, i.e., that the price specified is >= that the number of minutes being requested * the minimum number of weis per minute, as specified during request creation).

After a short while, the offer is created and linked to the request created at step 2.

### Step 3: Selecting the offer and generating an access token for it

The last step with regard to the marketplace interactions is the request decision process. In this simulated use case, there is only one offer submitted, which is also the one that is going ot be selected. To do so, with action n. 2) select the Ethereum account that was used to create the request, as only the request creator can perform management operations (i.e., close and decide) on a request. After that, select action n. 7) and specify the IDs of the request and the offer created in step 1 and 2 respectively.

The decision progress will update the marketplace state to reflect the actions performed and will trigger the Interledger data transfer that will eventually lead to the generation and logging of an access token on the authorization blockchain. After the access token is registered on the authorization blockchain, the access token content is forwarded to the marketplace blockchain with another Interledger data transfer, this time in reverse direction. With this deployment, the whole process takes around 5 seconds.

### Step 4: Retrieving the access token

Once the access token has been generated and communicated to the marketplace blockchain via an Interledger data transfer, it can be retrieved and decrypted by the offer creator.

>In this case, everything happens in the CLI app provided, but in production deployments the keys to decrypt the access token would be owned and managed by the smart locker renter client used to perform the marketplace operations.

To decrypt and decode the access token, select action n. 11). The output shows the encrypted token that was generated and the decrypted and decoded access token, which includes information about locker ID (the `aud` field), starting time (the `nbf` field), and expiration time (the `exp` field) as specified in the offer created in step 2.

### Step 5: Providing evidence of resource delivery

With the freshly generated access token, the renter is now able to use the smart locker for the time range purchased. Once the renter accesses the locker, it will provide evidence to the marketplace that access was indeed granted with the generated access token. To provide resource delivery evidence to the marketplace, switch to the Ethereum account used to create the offer (as evidence can only be provided by the entity using the resource, i.e., the access token in this case) and select action n. 8). Here, provide the IDs of the request and the offer to which the access token was issued.

>The evidence can be provided only once, and further attemps to perform the same action will result in errors.

### Step 6: Claiming the money for the service offered

Once the access token has been issued and the renter has provided evidence that it can be used to access the smart locker, the locker owner can claim the money (in weis, Ethereum's native cryptocurrency) that was escrowed in the marketplace smart contract during offer creation. To do so, switch to the Ethereum account of the request creator, select action n. 9), and specify the ID of the offer that has been fulfilled by issuing a valid access token. This operation will allow the locker owner to withdraw the weis escrowed in the offer and increase its total balance.

### Print all the key events

At the end of the whole chain of interactions, the key events generated by the marketplace blockchain can be printed as a proof that all important operations have been immutably stored on the blockchain and can be used in case of dispute resolutions. To print the events generated, select action n. 12).
