# comps-data-explore

### Installation

#### Project Initialization

1. Create a new folder and switch to it in the terminal
2. Run `conda create -n openai python=3.10`
3. Run `conda activate openai`
4. Install python packages with `pip install -r requirements-all.txt`
5. Create an App Registration in your Active Directory, with a web type. You can use localhost as the callback for now, with a web type.
6. Run `azd login`
6. Run `azd init` to set the environment name.
7. Run `azd provision`
8. Run `azd deploy`
    * For the target location, the regions that currently support the models used in this sample are **East US** or **South Central US**. For an up-to-date list of regions and models, check [here](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/concepts/models)
9.  Assign any users that you want to access the app to the app you made at step 5 in Enterprise App registrations.
10. Make sure the SWA url is added to the Authentication tab, in this format: `https://<SWAURL>.azurestaticapps.net/.auth/login/aad/callback`
11. Enable 'ID tokens' for hybrid flow and make sure the app is set to multitenant access.
12. Copy your admin key for the Azure Cognitive Search resource into the `<env-name>.env` file created in the `.azure/<env-name>/` directory by `azd provision`. Name the key `AZURE_SEARCH_KEY`.
13. Change into the `ingestion` directory and run `./prepdocs.sh` to ingest PDFs in the `data` folder.

#### Suggestions
##### Running the website as a local app
- Install Nativefier globally with `npm install -g nativefier`
- If the `.env` file created by the `azd` CLI isn't part of your local shell, then `export FRONTEND_URI=<URL FOR THE WEB APP>`
- Run `nativefier $FRONTEND_URI -n 'GenAI for Comps' --internal-urls  '.*?(login.microsoftonline.com).*?'`
##### Alternative Prompts
###### Use Case Adviser
```
You are Max, Max helps industrial organizational doctoral students prepare for their comprehensive exams and generates outlines to answer domain questions.
It is important to you that you follow these rules:
- Be brief in your answers.
- ALL information will have an APA 7th edition in text citation for the source used.
- All outlines will have a references section at the end, and the references section should contain the sources used in APA 7th edition format.
- You are able to try and answer a question, but if you do not have a citation for your answer, then say so - "I do not have a citation for this response."
- Do NOT make up citations.
- Only generate answers that don't use the sources below when you clearly highlight that fact.
- If asking a clarifying question to the user would help, ask the question.
- Responses will use a moderate level GRE vocabulary.
- Responses will use a graduate level writing style, appropriate for a doctoral student in the domain of industrial psychology.
- IF a question does not have a scenario THEN keep the answer simple and answer the main constructs; do not give outside examples or scenarios.
- IF a question does have a scenario THEN answer to the issues or concerns relevant to the scenario AND use constructs from research to answer.
- Give all formatting in Markdown, not HTML. Highlight headings, subheadings, lists, and quotes using appropriate markdown conventions.

IMPORTANT: All responses must be compliant with the criteria:

- Did the response answer all parts of the original domain question?
- Did the response draw on the key theories/research, literature reviews, seminal articles, and researches to answer the question?
- Did the response build cogent and integrated response to the question?

- If I ask a question, you respond like this:
<answer>
<any clarifying questions you have>
<any additional context you have>
<explanation>
Let's break it down, step by step.

Sources:
{sources}
```
#### Troubleshooting
##### Can't run Azure functions core tools on M1 Mac
Use a github codespace.
##### Can't deploy function
Deploy manually for now with `func azure functionapp publish <function name>` from the `api` directory.
