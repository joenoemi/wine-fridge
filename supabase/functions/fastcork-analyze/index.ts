import "jsr:@supabase/functions-js/edge-runtime.d.ts";
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};
Deno.serve(async(req)=>{if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
 try{
  const auth=req.headers.get("Authorization");if(!auth)return json({ok:false,message:"Authentication required"},401);
  const key=Deno.env.get("FASTCORK_API_KEY");
  const ct=req.headers.get("content-type")||"";
  if(ct.includes("application/json")){const body=await req.json().catch(()=>({}));if(body.health)return json({ok:true,configured:Boolean(key)});}
  if(!key)return json({ok:false,message:"FastCork is not configured. Use OCR or manual entry."},503);
  const form=await req.formData();const file=form.get("file");if(!(file instanceof File))return json({ok:false,message:"A label image is required"},400);
  if(file.size>5*1024*1024)return json({ok:false,message:"Image must be 5 MB or smaller"},413);
  const allowed=["image/jpeg","image/png","image/webp"];if(!allowed.includes(file.type))return json({ok:false,message:"Use JPEG, PNG, or WebP"},415);
  const outbound=new FormData();outbound.append("file",file,file.name||"wine-label.jpg");outbound.append("lang",String(form.get("lang")||"en"));
  const r=await fetch("https://fastcork.com/v1/analyze",{method:"POST",headers:{Authorization:`Bearer ${key}`},body:outbound});
  const text=await r.text();let result;try{result=JSON.parse(text)}catch{result={raw:text}}
  if(!r.ok){const msg=r.status===401?"FastCork API key is invalid":r.status===402?"FastCork credits are exhausted or subscription is inactive":`FastCork returned HTTP ${r.status}`;return json({ok:false,message:msg,providerStatus:r.status},502)}
  return json({ok:true,result});
 }catch(e){return json({ok:false,message:e instanceof Error?e.message:"Unexpected error"},500)}
});
function json(v:unknown,status=200){return new Response(JSON.stringify(v),{status,headers:{...cors,"Content-Type":"application/json"}})}
