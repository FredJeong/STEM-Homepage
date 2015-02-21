#-*-coding: utf-8 -*-
from app import app, api, db, models
from flask import render_template, Response
from flask.ext.restful import Resource, reqparse, fields, marshal_with
import datetime


@app.route('/')
def main():
    #DB dummy
    bannerRec1 = [
        {'image':'main_img.gif'}, 
        {'image':'1.jpg'}, 
        {'image':'2.jpg'}, 
        {'image':u'교육기부박람회1.JPG'}]
    boardRec1 = [
        {'idx':42,'title':'TEST1','date':'2014-01-31','new':True},
        {'idx':43,'title':'TEST2','date':'2014-01-28','new':False},
        {'idx':44,'title':'TEST3','date':'2014-01-20','new':False},
        {'idx':45,'title':'TEST4','date':'2014-01-19','new':False},
        {'idx':46,'title':'TEST5','date':'2014-01-17','new':False}]
    boardRec2 = [
        {'idx':42,'title':'QnA1','date':'2014-01-31','new':True},
        {'idx':43,'title':'QnA2','date':'2014-01-30','new':True},
        {'idx':44,'title':'QnA3','date':'2014-01-20','new':False},
        {'idx':45,'title':'QnA4','date':'2014-01-19','new':False},
        {'idx':46,'title':'QnA5','date':'2014-01-17','new':False}]
    return render_template('main.html', bannerRec1=bannerRec1, boardRec1=boardRec1, boardRec2=boardRec2) 

@app.route('/sub/<string:sub>')
def showSub(sub):
    mNum = sub[0]
    sNum = sub[2]
    if mNum == '5':
        return showBoard(sub, 1)
    return render_template('sub' + mNum + '_' + sNum + '.html', Session={'useridx':1}, mNum=int(mNum), sNum=int(sNum))

@app.route('/sub/<string:sub>/<int:page>')
def showBoard(sub, page):
    mNum = sub[0]
    sNum = sub[2]
    pagenation = models.Post.query.filter_by(
        board_id=int(sNum)).order_by(
        models.Post.timestamp.desc()).paginate(
        page, per_page=10)

    
    return render_template('sub' + mNum + '_' + sNum + '.html',
            page=page,totalpage=pagenation.pages,
            posts=pagenation.items,Session={'useridx':1},
            mNum=int(mNum), sNum=int(sNum))

@app.route('/post/<int:id>/view')
def viewPost(id):
    post = models.Post.query.get(id)
    post.hitCount = post.hitCount + 1
    db.session.commit()
    return render_template('sub5_2.html',mNum=5, sNum=2, mode='view', post=post, Session={'useridx':1})

@app.route('/post/<int:id>/modify')
def modifyPost(id):
    board = {}
    user = {'id':1, 'name':'Fred'}
    post = {'id':32, 'title': 'test', 'name':'test', 'board':board, 'author':user, 'body':'test','date':'2015-02-14'}
    return render_template('sub5_2.html',mNum=5, sNum=2, mode='modify', post=post, Session={'useridx':1})

@app.route('/post/<int:id>/reply')
def replyPost(id):
    board = {}
    user = {'id':1, 'name':'Fred'}
    post = {'id':32, 'title': 'test', 'name':'test', 'board':board, 'author':user, 'body':'test','date':'2015-02-14'}
    return render_template('sub5_2.html',mNum=5, sNum=2, board=board, mode='reply', post=post, Session={'useridx':1})




@app.route('/test')
def test():
    lst = []
    for i in range(10):
        lst.append({'number':i, 'name': 'Item ' + str(i*3)})
    return render_template('test_one.html', items=lst)

class WritePost(Resource):
    def get(self):
        boardParser = reqparse.RequestParser()
        boardParser.add_argument('board', type=int, required=True)

        args = boardParser.parse_args()
        board = models.Board.query.get(args['board'])
        user = models.User.query.get(1)
        return Response(
            render_template('sub5_2.html',mNum=5, sNum=2, mode='write', board=board, Session=user),
            mimetype='text/html')
    
    def post(self):
        postParser = reqparse.RequestParser()
        postParser.add_argument('title', type=str)
        postParser.add_argument('body', type=str)
        postParser.add_argument('userID', type=int)
        postParser.add_argument('boardID', type=int)
        postParser.add_argument('level', type=int)

        args = postParser.parse_args()
        post = models.Post(
            args['level'], args['title'], args['body'], args['userID'], args['boardID'])
        db.session.add(post)
        db.session.commit()

api.add_resource(WritePost, '/post/write')