Shader "Unlit/Mask Texture Directional" { //by Jake Rodelius

	// -- DESCRIPTION --
	// This shader is used on a Mesh to reveal a static texture "behind", like a mask.
	// This "Directional" version binds transparency to how directly the normals face the "Revealed Direction"

	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Color("Tint Color", Color) = (1, 1, 1, 1)
		_Opacity("Maximum Opacity", Range(0.0, 1.0)) = 1.0

			//The world space direction where the opacity is at its highest
		_RevealedDirection("Revealed Direction", Vector) = (0, 0, -1, 0) //These components should all add up to one

			//When the direction of the faces normal is less than minimum% facing the intended direction, it will be opacity 0
		_MinimumHide("Minimum Visibility", Range(0.0, 1.0)) = 0.2
			//When the direction of the faces normal is more than maximum% facing the intended direction, it will be Maximum Opacity
		_MaximumHide("Maximum Visibility", Range(0.0, 1.0)) = 0.8
	}

	SubShader{
		//enable transparency with these 3 lines
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST; //Offset values function between 0 and (texture size).
				fixed4 _Color;
				float _Opacity;

				float _MinimumHide; //When the direction of the faces normal is less than minimum% facing the intended direction, it will be opacity 0
				float _MaximumHide; //When the direction of the faces normal is more than maximum% facing the intended direction, it will be Maximum Opacity
				float4 _RevealedDirection;

				struct appdata {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float3 normal : NORMAL;
					UNITY_VERTEX_INPUT_INSTANCE_ID //not sure how important this is
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 texcoord : TEXCOORD0;
					float4 alignment : COLOR; //not actually a color. Semantics required I guess. This is the percent aligned the normal is.
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

					//opacity is the result of comparing the current normal direction and the normal direction you want the opacity to be 1 while facing
					float3 worldNormal = UnityObjectToWorldNormal(v.normal);
					o.alignment.xyz = worldNormal * _RevealedDirection;
					o.alignment.a = o.alignment.x + o.alignment.y + o.alignment.z;

					return o;
				}

				fixed4 frag(v2f i, float4 screenPos : SV_POSITION) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, float2(screenPos.x / _MainTex_ST.x + _MainTex_ST.z / _MainTex_ST.x, -screenPos.y / _MainTex_ST.y + _MainTex_ST.w / _MainTex_ST.y)); //determines color using the screen position of this fragment and the main texture. Main texture uses tiling and offset.
					col.rgb = col.rgb * _Color.rgb; //tint
					col.a = _Opacity * clamp((i.alignment.a - _MinimumHide) / (_MaximumHide-_MinimumHide), 0.0f, 1.0f); //this expression makes the opacity falloff between min and max
					return col;
				}
			ENDCG
		}
	}
}
