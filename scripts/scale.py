"""Large coprime cycles require visiting their product, not copying every access word."""
import json,math
from reference import invoke
def cycle(n):
    return {'states':[str(i) for i in range(n)],'initial':'0','alphabet':['tick'],'transitions':[{'from':str(i),'input':'tick','to':str((i+1)%n),'output':0} for i in range(n)]}
a,b=cycle(127),cycle(128)
result=invoke(dict(old=a,new=b));assert result['verdict']=='equivalent';assert result['visited_pairs']==math.lcm(127,128)
bounded=invoke(dict(old=a,new=b,max_pairs=100));assert bounded['verdict']=='unknown';assert bounded['visited_pairs']==100
print(json.dumps(dict(product_pairs=result['visited_pairs'],bounded_pairs=bounded['visited_pairs'],checks=2)))
