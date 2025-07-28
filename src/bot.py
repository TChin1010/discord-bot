'''
Author: Tyler Chin

This class contains the backend for the client including methods and
any field values
'''

import discord
import requests
import json
import src.log as log

from random import randint
from discord.ext import commands

intents = discord.Intents.all()
intents.message_content = True
bot = commands.Bot(command_prefix="!", intents=intents, activity=discord.CustomActivity(name='Scrolling Reels'), help_command=None)


# Bot commands and events
@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}')

@bot.event
async def on_member_join(member):
    '''
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
    Sends a help page to the user
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
        embed.add_field(name='lateststocks', value='View the latest and hottest stocks!')
        embed.add_field(name='subwaysufers', value='subway sufers')
        await ctx.send(embed=embed)
    except:
        print('Error !help')
        log.reportCommand('!help', env)

@bot.command()
async def brainrotmax(ctx):
    '''
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
    Help the user "stay concentrated"
    '''
    await ctx.send('https://tenor.com/b1ADJ.gif')
@bot.command()
async def crypto8ball(ctx):
    '''
    Get the latest stocks from twelve data
    '''
    env = {}

    try:
        api = requests.get('https://api.twelvedata.com/stocks?source=docs')
        print(api.text)
    except:
        print('Error !lateststocks')
        log.reportCommand('lateststocks', env)


# main
if __name__ == "src.bot":
    with open('src\\env.json', 'r') as file:
        env = json.load(file) # extracts the json evniroment

    bot.run(env['login_token'])