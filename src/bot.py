'''
Author: Tyler Chin

This class contains the backend for the client including methods and
any field values
'''

import discord
import requests
import json
import src.log as log
import nbformat
import os
import schedule
import time
import asyncio

from google import genai
from random import randint
from discord.ext import commands
from nbclient import NotebookClient


intents = discord.Intents.all()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents, activity=discord.CustomActivity(name='Scrolling Reels'), help_command=None)


def update_bitcoin_script():
    '''
    @Author: Tyler Chin

    Updates the notebook script every 24 hours to get the 
    latest the greatest data!
    '''
    with open('src\\bitcoin.ipynb') as f:
            nb = nbformat.read(f, as_version=4)

    NotebookClient(nb).execute()

# Bot commands and events
@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')

@bot.event
async def on_member_join(member):
    '''
    @Author

    Send a welcome sticker to a perosn who joins a server
    '''

    channel = member.guild.system_channel

    join_message = [msg async for msg in channel.history(limit=1)][0]
    messages = ['Welcome welcome', 'Sup Sup', 'I dont know what else to write',
                'Hows the weather', 'Want to get some pizza?']
    await join_message.reply(messages[randint(0, len(messages) - 1)])
  
@bot.command()
async def help(ctx):
    '''
    @Author: Tyler

    Sends a help page to the user to show them all controls
    '''
    env = {}
    try:
        embed = discord.Embed(
            title = 'Help Page',
            description = 'All the following commands start with !',
            color = discord.Color.blue()
        )
        env['env'] = embed
        embed.add_field(name='hi', value='Whats the bot up to right now? Find out with this command!')
        embed.add_field(name='brainrot', value='Get the latest brainrot today!')
        embed.add_field(name='latestBTC', value='View the latest and hottest Bitcoin updates!')
        embed.add_field(name='askGemini', value='Ask Gemini 2.0 about random questions you might have!')
        embed.add_field(name='subwaysufers', value='subway sufers')
        await ctx.send(embed=embed)
    except:
        print('Error !help')
        log.reportCommand('!help', env)

@bot.command()
async def brainrotmax(ctx):
    '''
    @Author: Tyler Chin

    Sends a randomly selected reddit hot meme
    on r/memes!
    '''
    env = {}
    try:
        api : dict = requests.get('https://www.reddit.com/r/memes/hot.json').json()
        env['api'] = api

        randPost = randint(0, len(api['data']['children']) - 1)
        env['randPost'] = randPost

        env['url'] = api['data']['children'][randPost]['data']['url']
        await ctx.send(api['data']['children'][randPost]['data']['url'])
    except:
        print('Error !brainrotmax')
        log.reportCommand('!brainrotmax', env)

@bot.command()
async def subwaysurfers(ctx):
    '''
    @Author: Tyler Chin

    Help the user "stay concentrated"
    '''
    await ctx.send('https://tenor.com/b1ADJ.gif')

@bot.command()
async def askGemini(ctx, *, message):
    '''
    @Author: Tyler Chin

    The user can ask Gemini any question that is passed through <message>
    '''
    with open('src\\env.json', 'r') as file:
        env = json.load(file) # extracts the json evniroment
    
    client = genai.Client(api_key=env['gemini_token'])

    response = client.models.generate_content(
        model="gemini-2.0-flash", contents= message + ". in less than 200 words"
    )
    await ctx.send(response.text)
    
@bot.command()
async def latestBTC(ctx):
    '''
    @Author: Tyler Chin

    Get the latest Bitcoin data with this prediction model
    '''
    env = {}
    
    # Load notebook
    try:
        with open('src\\bitcoin.ipynb') as f:
            nb = nbformat.read(f, as_version=4)
            env['nb'] = nb

        # Loop through cells and print stored outputs
        for cell in nb.cells:
            if "outputs" in cell:
                for output in cell["outputs"]:
                    if output.output_type == "execute_result":
                        data = output["data"]['text/plain']
        
        env['data'] = data
        data = data[1:-1]
        data = data.split(', ')
        message = 'Yesterdays closing value for BTC was $' + data[0] + '. My predicted closing value is $' + data[1]
        await ctx.send(message)
    except:
        print('Error !lateststocks')
        log.reportCommand('lateststocks', env)

# main
if __name__ == "src.bot":
    schedule.every().day.at('00:00').do(update_bitcoin_script)
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    with open('src\\bitcoin.ipynb') as f:
            nb = nbformat.read(f, as_version=4)

    NotebookClient(nb).execute()

    with open('src\\env.json', 'r') as file:
        env = json.load(file) # extracts the json evniroment

    bot.run(env['login_token'])

    while True:
        schedule.run_pending()
        time.sleep(1)