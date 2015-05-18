#-*-coding: utf-8 -*-
from app import app, api, db, models, lm
from flask import render_template, Response, redirect, url_for, request
from flask.ext.restful import Resource, reqparse, fields, marshal_with
from flask.ext.login import login_user, logout_user, current_user, login_required
from .forms import LoginForm, RegisterForm, ModifyForm, ModifyMemberForm
from sqlalchemy import and_
import datetime



@lm.user_loader
def load_user(id):
    return models.User.query.get(int(id))

@app.route('/')
def main():
    bannerRec1 = [
        {'image':'main_img.gif'}, 
        {'image':'1.jpg'}, 
        {'image':'2.jpg'}, 
        {'image':u'교육기부박람회1.JPG'}]

    boardRec1 = db.session.query(models.Post).filter_by(
        board_id=1).order_by(models.Post.timestamp.desc()).limit(5).all()
    boardRec2 = db.session.query(models.Post).filter_by(
        board_id=2).order_by(models.Post.timestamp.desc()).limit(5).all()

    for post in boardRec1:
        now = datetime.datetime.utcnow()
        post.date = post.timestamp.strftime('%m.%d')
        if now - post.timestamp < datetime.timedelta(days=3):
            post.new = True

    for post in boardRec2:
        now = datetime.datetime.utcnow()
        post.date = post.timestamp.strftime('%m.%d')
        if now - post.timestamp < datetime.timedelta(days=3):
            post.new = True


    return render_template('main.html',
        bannerRec1=bannerRec1, boardRec1=boardRec1, boardRec2=boardRec2,
        form=LoginForm())

@app.route('/sub/<string:sub>')
def showSub(sub):
    mNum = sub[0]
    sNum = sub[2]
    if mNum == '5':
        return showBoard(sub, 1)
    elif mNum == '3':
        return redirect('/sub/3-1/1')
    elif mNum == '2' and sNum == '5':
        year = datetime.date.today().year
        return redirect('/sub/2-5/%d' % year)
    return render_template('sub' + mNum + '_' + sNum + '.html',
        mNum=int(mNum), sNum=int(sNum), form=LoginForm())

@app.route('/sub/<string:sub>/<int:page>')
def showBoard(sub, page):
    mNum = sub[0]
    sNum = sub[2]

    if mNum == '5':
        pagenation = models.Post.query.filter_by(
            board_id=int(sNum)).order_by(
            models.Post.timestamp.desc()).paginate(
            page, per_page=10)

        
        return render_template('sub' + mNum + '_' + sNum + '.html',
                page=page,totalpage=pagenation.pages,
                posts=pagenation.items,
                mNum=int(mNum), sNum=int(sNum),
                form=LoginForm())

    elif mNum == '3':
        return showPeople(sub, page)

    elif mNum == '2' and sNum == '5':
        return showHistory(sub, page)


    return showSub(sub)

def showPeople(sub, page):
    mNum = sub[0]
    sNum = sub[2]

    yearRec = models.User.query.with_entities(models.Member.cycle).distinct().all()
    yearRec = sorted([y[0] for y in yearRec])
    try:
        yearRec.remove(0)
    except ValueError:
        pass
    if not page in yearRec:
        page = yearRec[0]
    allRec = models.Member.query.filter_by(cycle=page)
    return render_template('sub3_1.html',
        mNum=int(mNum), sNum=int(sNum), form=LoginForm(),
        yearRec=yearRec, people=allRec)

def showHistory(sub, page):
    mNum = sub[0]
    sNum = sub[2]

    year = datetime.date.today().year
    yearRec = [n for n in range(2010, datetime.date.today().year + 1)]
    if not page in yearRec:
        page = year
    start = datetime.datetime(page, 1, 1, tzinfo = datetime.timezone.utc)
    end = datetime.datetime(page, 12, 31, tzinfo = datetime.timezone.utc)
    allRec = db.session.query(models.Post).filter(
        and_(models.Post.timestamp.between(start, end),
            models.Post.board_id == 3
            )).order_by(models.Post.timestamp).all()

    for post in allRec:
        post.period = post.timestamp.strftime('%m.%d')
        if post.body and post.body != '':
            endDate = datetime.datetime.utcfromtimestamp(float(post.body))
            post.period = post.period + ' ~ ' + endDate.strftime('%m.%d')

    return render_template('sub2_5.html',
        mNum=int(mNum), sNum=int(sNum), form=LoginForm(),
        years=yearRec, page=page, history=allRec)

@app.route('/post/<int:id>/view')
def viewPost(id):
    post = models.Post.query.get(id)
    post.hitCount = post.hitCount + 1
    db.session.commit()
    return render_template('sub5_2.html',mNum=5, sNum=2,
        mode='view', post=post,
        form=LoginForm())

@app.route('/post/<int:id>/modify')
def modifyPost(id):
    board = {}
    user = {'id':1, 'name':'Fred'}
    post = {'id':32, 'title': 'test', 'name':'test', 'board':board, 'author':user, 'body':'test','date':'2015-02-14'}
    return render_template('sub5_2.html',mNum=5, sNum=2,
        mode='modify', post=post,
        form=LoginForm())

@app.route('/post/<int:id>/reply')
def replyPost(id):
    board = {}
    user = {'id':1, 'name':'Fred'}
    post = {'id':32, 'title': 'test', 'name':'test', 'board':board, 'author':user, 'body':'test','date':'2015-02-14'}
    return render_template('sub5_2.html',mNum=5, sNum=2,
        board=board, mode='reply', post=post,
        form=LoginForm())

@app.route('/login', methods=['GET','POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        login_user(form.user)
        return redirect(form.next.data)

    return render_template('member/login.html', form=form)

@app.route('/member/register', methods=['GET', 'POST'])
def register():
    form = RegisterForm()
    if form.validate_on_submit():
        login_user(form.user)
        return redirect('/')
    else:
        return render_template('member/register.html', form=form)


@app.route('/member/modify', methods=['GET', 'POST'])
@login_required
def modify():
    if current_user.member:
        form = ModifyMemberForm()
        if form.validate_on_submit():
            return form.redirect()
        departments = models.Department.query.all()
        stem_departments = models.StemDepartment.query.all()
        return render_template('member/modify.html', form=form,
            departments=departments, stem_departments=stem_departments)
    else:
        form = ModifyForm()
        if form.validate_on_submit():
            return form.redirect()
        return render_template('member/modify.html', form=form)

@app.route('/logout')
def logout():
    form = LoginForm()
    logout_user()
    return redirect('/')

class WritePost(Resource):
    def get(self):
        boardParser = reqparse.RequestParser()
        boardParser.add_argument('board', type=int, required=True)

        args = boardParser.parse_args()
        board = models.Board.query.get(args['board'])
        user = models.User.query.get(1)
        return Response(
            render_template('sub5_%d.html' % args['board'],
                mNum=5, sNum=args['board'], mode='write', board=board,
                form=LoginForm()),
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
        return Response(
            render_template('sub5_%d.html' % args['boardID'],
                mNum=5, sNum=args['boardID'],
                form=LoginForm()),
            mimetype='text/html')

class IdCheck(Resource):
    def post(self):
        idparser = reqparse.RequestParser()
        idparser.add_argument('userid', type=str)

        args = idparser.parse_args()
        user = models.User.query.filter_by(username=args['userid']).first()
        if user is not None:
            return {'duplicate':True}
        else:
            return {'duplicate':False}

class ShowPeople(Resource):
    def get(self, cycle):
        people = models.Member.query.filter_by(cycle=cycle)
        return Response(render_template('people.html', people=people), mimetype='text/html')

api.add_resource(ShowPeople, '/view/people/<int:cycle>', endpoint='api.show_people')
api.add_resource(WritePost, '/post/write')
api.add_resource(IdCheck, '/member/register/idcheck')