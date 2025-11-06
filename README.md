FlashloanVolumeTrap

Purpose:
Detect sudden spikes in token transfer volume that may be caused by flashloan-based price manipulation, liquidation cascades, or coordinated MEV attacks.

This trap monitors the rolling average transfer volume of a token and triggers if the most recent block's transfer volume exceeds the average by a configurable threshold (e.g., 200%+ spike).

| Step                | Description                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `collect()`         | Reads the token's transfer volume for the current block and returns it as encoded bytes.                           |
| `shouldRespond()`   | Compares the latest volume to the average of previous samples. If the spike is above `THRESHOLD_BPS`, it triggers. |
| `response_function` | The response contract simply logs the incident for now (can be upgraded to pause or mitigate).                     |
