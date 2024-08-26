Shader "Post-Processing/EdgeDetection_DepthNormals"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    struct v2f
    {
        float4 pos : SV_POSITION;
        float2 uv[5] : TEXCOORD0;
    };

    sampler2D _MainTex;
    half4 _MainTex_TexelSize;
    sampler2D _CameraDepthNormalsTexture;
    fixed4 _EdgeColor,_BackgroundColor;

    fixed _EdgeOnly;
    float _SampleRange;//,_NormalThreshold,_DepthThreshold;
    half4 _Sensitivity;
    //ͨ�����ߺ����������Ƿ�Ϊ��Ե
    half CheckNormalAndDepthDiff(half4 center,half4 sample)
    {
        half2 centerNormal = center.xy;
        float centerDepth = DecodeFloatRG(center.zw);
        half2 sampleNormal = sample.xy;
        float sampleDepth = DecodeFloatRG(sample.zw);
        //���߼��
        half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
        int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
        //������
        float2 diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
        int isSameDepth = diffDepth < 0.1 * centerDepth;
        //������ߺ���ȶ����ƾͷ���1�����򷵻�0
        return isSameNormal * isSameDepth ? 1.0 : 0.0;
    }
    //ͨ�����߼���Ƿ�Ϊ��Ե
    half CheckNormalDiff(half4 center,half4 sample)
    {
        //����Ҫ�Է��߽��н��룬��Ϊ����ֻ��Ҫ�Ƚ�������ֵ֮��Ĳ�
        half2 centerNormal = center.xy;
        half2 sampleNormal = sample.xy;
        //���߼��
        half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
        int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
        
        return isSameNormal;
    }
    //ͨ����ȼ���Ƿ�Ϊ��Ե
    half CheckDepthDiff(half4 center,half4 sample)
    {
        float centerDepth = DecodeFloatRG(center.zw);
        float sampleDepth = DecodeFloatRG(sample.zw);
        //������
        float2 diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
        int isSameDepth = diffDepth < 0.1 * centerDepth;
        
        return isSameDepth;
    }

    v2f vert(appdata_img v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);

        half2 uv = v.texcoord;
        o.uv[0] = uv;
        //��Ϊ��������������Ҫ����ƽ̨���컯����
        #if UNITY_UV_STARTS_AT_TOP
        if(_MainTex_TexelSize.y < 0){
            uv.y = 1 - uv.y;
        }
        #endif
        //Robert���ӱ���:�������ϽǺ����½ǣ����Խ��ߵĲ�ֵ
        o.uv[1] = uv + _MainTex_TexelSize * half2( 1, 1) * _SampleRange;
        o.uv[2] = uv + _MainTex_TexelSize * half2(-1,-1) * _SampleRange;
        o.uv[3] = uv + _MainTex_TexelSize * half2(-1, 1) * _SampleRange;
        o.uv[4] = uv + _MainTex_TexelSize * half2( 1,-1) * _SampleRange;

        return o;
    }

    fixed4 frag_NormalDepth(v2f i) : SV_Target
    {
        fixed4 col = tex2D(_MainTex,i.uv[0]);
        half4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
        half4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
        half4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
        half4 sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);
        
        half edge = 1.0;
        edge *= CheckNormalAndDepthDiff(sample1,sample2);
        edge *= CheckNormalAndDepthDiff(sample3,sample4);

        fixed4 withEdgeColor = lerp(_EdgeColor,col,edge);
        fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);

        return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
    }
    fixed4 frag_Normal(v2f i) : SV_Target
    {
        fixed4 col = tex2D(_MainTex,i.uv[0]);
        half4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
        half4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
        half4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
        half4 sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);
        
        half edge = 1.0;
        edge *= CheckNormalDiff(sample1,sample2);
        edge *= CheckNormalDiff(sample3,sample4);

        fixed4 withEdgeColor = lerp(_EdgeColor,col,edge);
        fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);

        return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
    }
    fixed4 frag_Depth(v2f i) : SV_Target
    {
        fixed4 col = tex2D(_MainTex,i.uv[0]);
        half4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
        half4 sample2 = tex2D(_CameraDepthNormalsTexture,i.uv[2]);
        half4 sample3 = tex2D(_CameraDepthNormalsTexture,i.uv[3]);
        half4 sample4 = tex2D(_CameraDepthNormalsTexture,i.uv[4]);
        
        half edge = 1.0;
        edge *= CheckDepthDiff(sample1,sample2);
        edge *= CheckDepthDiff(sample3,sample4);

        fixed4 withEdgeColor = lerp(_EdgeColor,col,edge);
        fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);

        return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
    }
    ENDCG

    SubShader
    {
        ZWrite Off ZTest Always Cull Off
        //Pass 0-DepthNormal
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_NormalDepth
            ENDCG
        }
        //Pass 1-Normal
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_Normal
            ENDCG
        }
        //Pass 2-Depth
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_Depth
            ENDCG
        }
    }
    FallBack Off
}
