'''
This script logs any errors or bugs that are caught
by the discord bot
'''
from datetime import datetime
import json

def reportCommand(command: str, env: dict) -> None:
    '''
    @Author: Tyler Chin
    
    report bugs/errors that are a result of a command a user
    sent
    Args: 
        command (str): The command that caused the error
        env (list): A list of all variables related to the
                    During the error
    '''
    data = {}

    time = datetime.now()
    data['time'] = f'{time.day} {time.month}, {time.year}: {time.hour}:{time.minute}:{time.second}'
    data['command'] = command
    data['env'] = env

    with open('log.json', 'a') as log:
        json.dump(data, log)
    
    print('log updated')

def reportTimely(event: str, env):
    '''
    @Author: Tyler Chin
    
    report bugs/errors that are a result of an event
    Args: 
        event (str): The event that caused the error
        env (list): A list of all variables related to the
                    During the error
    '''
    data = {}

    time = datetime.now()
    data['time'] = f'{time.day} {time.month}, {time.year}: {time.hour}:{time.minute}:{time.second}'
    data['event'] = event
    data['env'] = env

    with open('log.json', 'a') as log:
        json.dump(data, log)
    
    print('log updated')