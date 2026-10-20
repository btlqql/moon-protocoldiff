"""Independent greatest-fixed-relation oracle; never calls product BFS internally."""
import itertools,json,random,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def invoke(request):
    r=subprocess.run(['node',str(ROOT/'_build/js/debug/build/cmd/main/main.js'),'-'],input=json.dumps(request),capture_output=True,text=True,check=False)
    if r.returncode not in (0,2,3):raise RuntimeError(r.stdout+r.stderr)
    return json.loads(r.stdout)
def edges(m):return {(e['from'],e['input']):(e['to'],e['output']) for e in m['transitions']}
def relation(a,b,mode):
    left,right=edges(a),edges(b);pairs=set(itertools.product(a['states'],b['states']))
    symbols=set(a['alphabet'])|(set(b['alphabet']) if mode=='equivalence' else set())
    while True:
        removed=set()
        for p,q in pairs:
            for s in symbols:
                x,y=left.get((p,s)),right.get((q,s))
                if mode=='backward' and x is None:continue
                if (x is None)!=(y is None) or (x is not None and (x[1]!=y[1] or (x[0],y[0]) not in pairs)):
                    removed.add((p,q));break
        if not removed:return pairs
        pairs-=removed
def differs(a,b,word,mode):
    left,right=edges(a),edges(b);p,q=a['initial'],b['initial']
    for s in word:
        x,y=left.get((p,s)),right.get((q,s))
        if x is None:return y is not None and mode=='equivalence'
        if y is None or x[1]!=y[1]:return True
        p,q=x[0],y[0]
    return False
def random_machine(rng):
    states=['s'+str(i) for i in range(rng.randint(1,3))];symbols=['a','b']
    return dict(states=states,alphabet=symbols,initial=states[0],transitions=[dict(from_=s,input=a,to=rng.choice(states),output=rng.choice([None,0,1,{'ok':True}])) for s in [] for a in []]) if False else {'states':states,'alphabet':symbols,'initial':states[0],'transitions':[{'from':s,'input':a,'to':rng.choice(states),'output':rng.choice([None,0,1,{'ok':True}])} for s in states for a in symbols if rng.random()<.8]}
def main():
    rng=random.Random(20261020);checks=0
    for i in range(60):
        a=random_machine(rng);b=random_machine(rng) if i%3 else json.loads(json.dumps(a))
        for mode in ['equivalence','backward']:
            expected=(a['initial'],b['initial']) in relation(a,b,mode)
            result=invoke(dict(old=a,new=b,mode=mode));assert (result['verdict'] in ['equivalent','compatible'])==expected,(a,b,result);checks+=1
            if not expected:
                word=result['word'];assert differs(a,b,word,mode)
                for n in range(len(word)):
                    assert not any(differs(a,b,list(w),mode) for w in itertools.product(['a','b'],repeat=n))
                assert invoke(dict(operation='verify_difference',old=a,new=b,mode=mode,word=word))['valid'];checks+=1
        minimized=invoke(dict(operation='minimize',machine=a));m=minimized['machine']
        assert (a['initial'],m['initial']) in relation(a,m,'equivalence');checks+=1
        # reachable equivalence class count independently from greatest relation.
        reached={a['initial']};lookup=edges(a)
        while True:
            expanded=reached|{target for (s,_),(target,_) in lookup.items() if s in reached}
            if expanded==reached:break
            reached=expanded
        eq=relation(a,a,'equivalence');classes=[]
        for state in sorted(reached):
            if not any((state,representative) in eq for representative in classes):classes.append(state)
        assert len(classes)==len(m['states']);checks+=1
        suite=invoke(dict(operation='suite',machine=a));words=[t['word'] for t in suite['tests']]
        audit=invoke(dict(operation='audit_suite',machine=a,tests=words));assert audit['complete'];checks+=1
        covered=set()
        for w in words:
            state=a['initial']
            for symbol in w:covered.add((state,symbol));state=lookup[state,symbol][0]
        assert covered=={k for k in lookup if k[0] in reached};checks+=1
    print(json.dumps(dict(seed=20261020,machine_pairs=60,independent_checks=checks)))
if __name__=='__main__':main()
