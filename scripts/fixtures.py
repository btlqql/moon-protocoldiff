"""Golden API assertions shared by core tests, CLI and registry consumer."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def machine(output=0):
    return {'states':['closed','open'],'initial':'closed','alphabet':['open','send','close'],'transitions':[
        {'from':'closed','input':'open','to':'open','output':'ok'},
        {'from':'open','input':'send','to':'open','output':output},
        {'from':'open','input':'close','to':'closed','output':'bye'}]}
old=machine();new=machine(1)
cases=[]
def add(name,request,expected,exit=0):cases.append(dict(name=name,request=request,expected=expected,exit=exit))
add('identical machines',dict(old=old,new=old),{'verdict':'equivalent'})
add('delayed output difference',dict(old=old,new=new),{'verdict':'different','word':['open','send'],'shortest':True},2)
add('difference verifier',dict(operation='verify_difference',old=old,new=new,word=['open','send']),{'verdict':'valid_difference'})
add('false difference rejected',dict(operation='verify_difference',old=old,new=new,word=['open']),{'verdict':'invalid_difference'},2)
add('run rejects undefined',dict(operation='run',machine=old,word=['send']),{'accepted':False,'rejected_at':0})
add('run records outputs',dict(operation='run',machine=old,word=['open','send','close']),{'accepted':True,'outputs':['ok',0,'bye']})
add('analyze reachable',dict(operation='analyze',machine=old),{'reachable':['closed','open'],'missing_transitions':3})
add('minimized verified',dict(operation='minimize',machine=old),{'minimized_states':2,'equivalence_verified':True})
add('transition suite',dict(operation='suite',machine=old),{'verdict':'complete','reachable_transitions':3,'reset_required':True})
add('suite bound',dict(operation='suite',machine=old,max_tests=1),{'verdict':'unknown'},3)
add('suite audit',dict(operation='audit_suite',machine=old,tests=[['open','send','close']]),{'complete':True,'covered_transitions':3})
add('suite missing edge',dict(operation='audit_suite',machine=old,tests=[['open']]),{'complete':False,'covered_transitions':1})
add('suite rejected test',dict(operation='audit_suite',machine=old,tests=[['send']]),{'rejected_tests':[{'test':0,'rejected_at':0}]})
add('pair budget unknown',dict(old=old,new=old,max_pairs=1),{'verdict':'unknown'},3)
add('step budget unknown',dict(old=old,new=old,max_steps=1),{'verdict':'unknown'},3)
extended=json.loads(json.dumps(old));extended['transitions'].append({'from':'closed','input':'send','to':'closed','output':None})
add('extension changes equivalence',dict(old=old,new=extended),{'verdict':'different','word':['send']},2)
add('extension backward compatible',dict(old=old,new=extended,mode='backward'),{'verdict':'compatible'})
for name,change in [('duplicate state',{'states':['closed','closed']}),('empty alphabet',{'alphabet':[]}),('undeclared initial',{'initial':'no'}),('extra machine property',{'extra':True})]:
    bad={**old,**change};add(name,dict(old=bad,new=old),{'verdict':'invalid_input'},64)
bad=json.loads(json.dumps(old));bad['transitions'].append(bad['transitions'][0]);add('nondeterminism rejected',dict(old=bad,new=old),{'verdict':'invalid_input'},64)
bad=json.loads(json.dumps(old));del bad['transitions'][0]['output'];add('output required',dict(old=bad,new=old),{'verdict':'invalid_input'},64)
add('mode validated',dict(old=old,new=old,mode='wrong'),{'verdict':'invalid_input'},64)
add('unknown option',dict(old=old,new=old,random=True),{'verdict':'invalid_input'},64)
add('zero budget',dict(old=old,new=old,max_pairs=0),{'verdict':'invalid_input'},64)
(ROOT/'tests').mkdir(exist_ok=True);(ROOT/'examples').mkdir(exist_ok=True)
(ROOT/'tests/cases.json').write_text(json.dumps(cases,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
(ROOT/'examples/session-diff.json').write_text(json.dumps({'old':old,'new':new},indent=2)+'\n')
literal=lambda v:json.dumps(json.dumps(v,ensure_ascii=False,separators=(',',':')),ensure_ascii=False)
code='///|\nfn selected(value : Json, parts : Array[String]) -> Json {\n let mut current=value\n for part in parts {current=match current {Json::Object(fields)=>fields[part]; _=>abort("fixture path")}}\n current\n}\n'
for case in cases:
    code+='\n///|\ntest '+json.dumps(case['name'])+' {\nlet result=execute(@json.parse('+literal(case['request'])+'))\n'
    for key,expected in case['expected'].items():code+='assert_eq(from_json(selected(result,'+json.dumps(key.split('/'))+')),from_json(@json.parse('+literal(expected)+')))\n'
    code+='}\n'
(ROOT/'fixtures_wbtest.mbt').write_text(code,encoding='utf8')
print('Generated',len(cases),'golden cases')
