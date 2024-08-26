Shader "Post-Processing/Glitch/RGBSplitGlitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half _Fading,_CenterFading,_RAmount,_BAmount;
        float _TimeX,_Amount,_Speed;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        half4 frag_horizontal(v2f i) : SV_Target
        {
            half time = _TimeX * 6 * _Speed;
            half splitAmount = (1.0 + sin(time)) * 0.5;
            splitAmount *= 1.0 + sin(time * 2) * 0.5;
            splitAmount = pow(splitAmount,3.0);
            splitAmount *= 0.05;
            float distance = length(i.uv - float2(0.5,0.5));
            splitAmount *= _Fading * _Amount;
            splitAmount *= lerp(1,distance,_CenterFading);

            half3 colorR = tex2D(_MainTex,float2(i.uv.x + splitAmount * _RAmount,i.uv.y)).rgb;
            half4 col = tex2D(_MainTex,i.uv);
            half3 colorB = tex2D(_MainTex,float2(i.uv.x - splitAmount * _RAmount,i.uv.y)).rgb;

            half3 splitColor = half3(colorR.r,col.g,colorB.b);
            half3 finalColor = lerp(col.rgb,splitColor,_Fading);

            return half4(finalColor,1.0);
        }

        half4 frag_vertical(v2f i) : SV_Target
        {
            half time = _TimeX * 6 * _Speed;
            half splitAmount = (1.0 + sin(time)) * 0.5;
            splitAmount *= 1.0 + sin(time * 2) * 0.5;
            splitAmount = pow(splitAmount,3.0);
            splitAmount *= 0.05;
            float distance = length(i.uv - float2(0.5,0.5));
            splitAmount *= _Fading * _Amount;
            splitAmount *= _Fading * _Amount;

            half3 colorR = tex2D(_MainTex,float2(i.uv.x,i.uv.y + splitAmount * _RAmount)).rgb;
            half4 col = tex2D(_MainTex,i.uv);
            half3 colorB = tex2D(_MainTex,float2(i.uv.x,i.uv.y - splitAmount * _RAmount)).rgb;

            half3 splitColor = half3(colorR.r,col.g,colorB.b);
            half3 finalColor = lerp(col.rgb,splitColor,_Fading);

            return half4(finalColor,1.0);
        }

        half4 frag_vertical_horizontal(v2f i) : SV_Target
        {
            half time = _TimeX * 6 * _Speed;
            half splitAmount = (1.0 + sin(time)) * 0.5;
            splitAmount *= 1.0 + sin(time * 2) * 0.5;
            splitAmount = pow(splitAmount,3.0);
            splitAmount *= 0.05;
            float distance = length(i.uv - float2(0.5,0.5));
            splitAmount *= _Fading * _Amount;
            splitAmount *= _Fading * _Amount;

            float splitAmountR = splitAmount * _RAmount;
            float splitAmountB = splitAmount * _BAmount;

            half3 colorR = tex2D(_MainTex,float2(i.uv.x + splitAmountR ,i.uv.y + splitAmountR)).rgb;
            half4 col = tex2D(_MainTex,i.uv);
            half3 colorB = tex2D(_MainTex,float2(i.uv.x - splitAmountB,i.uv.y  - splitAmountB)).rgb;

            half3 splitColor = half3(colorR.r,col.g,colorB.b);
            half3 finalColor = lerp(col.rgb,splitColor,_Fading);

            return half4(finalColor,1.0);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_horizontal
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_vertical
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_vertical_horizontal
            ENDCG
        }
    }
}
