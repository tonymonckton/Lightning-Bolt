/*
    Tony Monckton, April 2023.

    fake lighning bolt.
*/

Shader "Unlit/Lighning"
{
    Properties
    {
        _MainTex    ("Texture",     2D) = "white" {}
        _ScaleX     ("Scale X", Float) = 1.0
        _ScaleY     ("Scale Y", Float) = 1.0

        _Brightness ("Brightness",  Range(0.0, 5.0)) = 1.0

        _AlphaBlendL ("Alpha Blend Left", Range(0,0.999)) = 0.2
        _AlphaBlendR ("Alpha Blend Right", Range(0,0.999)) = 0.2
        _TimeSpeed  ("Time Speed",  Range(0.0, 2.0)) = 1.0
        _Power      ("Power Value", Range(0,1)) = 0.5
        
        _Frequency1 ("Frequency 1", Range(0.0,1.0)) = 0.21
        _Frequency2 ("Frequency 2", Range(0.0,1.0)) = 0.22
        _Frequency3 ("Frequency 3", Range(0.0,1.0)) = 0.23
        _Speed1     ("Speed 1",     Range(0.0,1.0)) = 0.53534
        _Speed2     ("Speed 2",     Range(0.0,1.0)) = 0.64563
        _Speed3     ("Speed 3",     Range(0.0,1.0)) = 0.73425
    }
    SubShader
    {
        Tags {
                "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
                "DisableBatching" = "True"  // to stop flickering
            }
        
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _MainTex;
            float4 _MainTex_ST;

            uniform float _ScaleX;
            uniform float _ScaleY;

            uniform float _Brightness;
            uniform float _AlphaBlendL;
            uniform float _AlphaBlendR;
            uniform float _TimeSpeed;
            uniform float _Power;
            uniform float _Frequency1;
            uniform float _Frequency2;
            uniform float _Frequency3;
            uniform float _Speed1;
            uniform float _Speed2;
            uniform float _Speed3;

            inline float Smoothstep(float a, float b, float x)
            {
                float t = saturate((x - a)/(b - a));
                return t*t*(3.0 - (2.0*t));
            }

            inline float4 Bolt2(float2 uv)
            {
                float3 col = float3(0.25,0.5,1.0)*max(0.0,1.0-pow(32.0*abs(0.5-uv.x),_Power));
                return float4(col,1.0);
            }

            float3 Bolt(float2 uv, float speed, float freq)
            {
                float3 col = float3(0.0,0.0,0.0);
                float2 tuv;

                for (float i=0.0; i<0.05; i+=0.01)
                {
                    float2 nuv = uv;

                   	nuv.x += 0.25*(0.5-tex2D(_MainTex,float2((_Time.y*_TimeSpeed - i)*speed, nuv.y*freq)).x)*pow(0.5-abs(0.5-uv.y), 0.1);
		            col += 0.5*Bolt2(nuv);
                }
                return col;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = float3(0.0, 0.0, 0.0);

                // sum the three bolts
                col += Bolt(i.uv, _Speed1, _Frequency1);
                col += Bolt(i.uv, _Speed2, _Frequency2);
                col += Bolt(i.uv, _Speed3, _Frequency3);

                // create alpha fading left and right.
                float alphaLeft  = Smoothstep(0.0,_AlphaBlendL,i.uv.y);
                float alphaRight = Smoothstep(1.0,_AlphaBlendR,i.uv.y);
                float a = (col.r + col.g + col.r) * alphaLeft * alphaRight;

                return fixed4(col.rgb*_Brightness, a);
            }
            ENDCG
        }
    }
}
