#-*-coding: utf-8 -*-
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.login import LoginManager
from flask.ext import restful
from flask.ext.admin import Admin
from flask.ext.admin.contrib.sqla import ModelView

app = Flask(__name__)
#app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://be3278fbbccac7:64de4292@us-cdbr-iron-east-01.cleardb.net/heroku_60fb971363678a5'
app.config.from_object('config')
app.secret_key='0087a3768e5285b2580d'
db = SQLAlchemy(app)
api = restful.Api(app)
lm = LoginManager()
lm.init_app(app)
admin = Admin(url='/admin',template_mode='bootstrap3')

from app import views, models, forms, config, admin_views, filters