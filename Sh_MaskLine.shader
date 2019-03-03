Shader "Unlit/Mask Line" { //by Jake Rodelius

	// -- DESCRIPTION --
	// This shader is used on a mesh to make transparent all pixels on one side of a line (in screen space)
	// Intended for wipe transitions, animating the offset property

	Properties{
		_Color("Tint Color", Color) = (1, 1, 1, 1)
		_Angle("Angle", Float) = 45.0 //Angle of the line
		_Offset("Offset", Float) = 0.0 //Position of the line
		_Gradient("Gradient", Float) = 10.0 //Width of the gradient
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

				fixed4 _Color;
				fixed4 _HiddenArea;
				float _Angle;
				float _Offset;
				float _Gradient;

				struct appdata {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					float3 normal : NORMAL;
					UNITY_VERTEX_INPUT_INSTANCE_ID //not sure how important this is
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float4 color : COLOR;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					return o;
				}

				fixed4 frag(v2f i, float4 screenPos : SV_POSITION) : SV_Target
				{
					fixed4 col = _Color;
					//col = fixed4(screenPos.x/1920, screenPos.y/1080, 0, 1); //just SV position values
					float angleInRadians = _Angle * 3.14159f / 180.0f;
					col.a = ((sin(angleInRadians) / cos(angleInRadians)) * screenPos.x + _Offset - screenPos.y) / max(_Gradient, 1); //solves mx+b for the screen position, if subtracting the pixel's y position results in a negative number it will be transparent
					col.a = clamp(col.a, 0, 1);
					return col;
				}
			ENDCG
		}
	}
}