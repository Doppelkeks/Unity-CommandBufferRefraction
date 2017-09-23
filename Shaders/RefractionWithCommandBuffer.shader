// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/RefractionWithCommandBuffer"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_AlbedoRGBBlurA("Albedo (RGB) Blur (A)", 2D) = "white" {}
		_MetallicRSmoothnessGOcclusionBOpacityA("Metallic (R) Smoothness (G) Occlusion (B) Opacity (A)", 2D) = "white" {}
		_NormalMapRGB("Normal Map (RGB)", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_DistortionStrength("Distortion Strength", Range( 0 , 1)) = 0.292
		_EmissionContribution("Emission Contribution", Range( 0 , 1)) = 0.3
		_ReflectionStrength("Reflection Strength", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform half _NormalScale;
		uniform sampler2D _NormalMapRGB;
		uniform float4 _NormalMapRGB_ST;
		uniform sampler2D _AlbedoRGBBlurA;
		uniform float4 _AlbedoRGBBlurA_ST;
		uniform sampler2D _GrabNoBlurTexture;
		uniform half _DistortionStrength;
		uniform sampler2D _GrabBlurTexture;
		uniform half _ReflectionStrength;
		uniform half _EmissionContribution;
		uniform sampler2D _MetallicRSmoothnessGOcclusionBOpacityA;
		uniform float4 _MetallicRSmoothnessGOcclusionBOpacityA_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMapRGB = i.uv_texcoord * _NormalMapRGB_ST.xy + _NormalMapRGB_ST.zw;
			float3 tex2DNode52 = UnpackScaleNormal( tex2D( _NormalMapRGB, uv_NormalMapRGB ) ,_NormalScale );
			o.Normal = tex2DNode52;
			float2 uv_AlbedoRGBBlurA = i.uv_texcoord * _AlbedoRGBBlurA_ST.xy + _AlbedoRGBBlurA_ST.zw;
			float4 tex2DNode53 = tex2D( _AlbedoRGBBlurA, uv_AlbedoRGBBlurA );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPos46 = ase_screenPos;
			#if UNITY_UV_STARTS_AT_TOP
			float scale46 = -1.0;
			#else
			float scale46 = 1.0;
			#endif
			float halfPosW46 = ase_screenPos46.w * 0.5;
			ase_screenPos46.y = ( ase_screenPos46.y - halfPosW46 ) * _ProjectionParams.x* scale46 + halfPosW46;
			#ifdef UNITY_SINGLE_PASS_STEREO
			ase_screenPos46.xy = TransformStereoScreenSpaceTex(ase_screenPos46.xy, ase_screenPos46.w);
			#endif
			ase_screenPos46.xyzw /= ase_screenPos46.w;
			float2 componentMask51 = ase_screenPos46.xy;
			float2 componentMask55 = ( tex2DNode52 * _DistortionStrength ).xy;
			float2 temp_output_54_0 = ( componentMask51 + componentMask55 );
			float4 lerpResult49 = lerp( tex2D( _GrabNoBlurTexture, temp_output_54_0 ) , tex2D( _GrabBlurTexture, temp_output_54_0 ) , tex2DNode53.a);
			float4 lerpResult91 = lerp( tex2DNode53 , lerpResult49 , _ReflectionStrength);
			o.Albedo = lerpResult91.xyz;
			o.Emission = ( _EmissionContribution * lerpResult91 ).xyz;
			float2 uv_MetallicRSmoothnessGOcclusionBOpacityA = i.uv_texcoord * _MetallicRSmoothnessGOcclusionBOpacityA_ST.xy + _MetallicRSmoothnessGOcclusionBOpacityA_ST.zw;
			float4 tex2DNode58 = tex2D( _MetallicRSmoothnessGOcclusionBOpacityA, uv_MetallicRSmoothnessGOcclusionBOpacityA );
			o.Metallic = tex2DNode58.r;
			o.Smoothness = tex2DNode58.g;
			o.Occlusion = tex2DNode58.b;
			o.Alpha = tex2DNode58.a;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d9 d3d11 glcore d3d11_9x 
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred nofog 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				float4 texcoords01 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.texcoords01 = float4( v.texcoord.xy, v.texcoord1.xy );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord.xy = IN.texcoords01.xy;
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13101
116;50;1906;1004;2407.126;1073.52;1.847712;True;True
Node;AmplifyShaderEditor.RangedFloatNode;63;-1710.117,-117.7083;Half;False;Property;_NormalScale;Normal Scale;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;57;-1393.535,52.59332;Half;False;Property;_DistortionStrength;Distortion Strength;6;0;0.292;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;52;-1405.301,-167.8068;Float;True;Property;_NormalMapRGB;Normal Map (RGB);4;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.GrabScreenPosition;46;-1336.204,-382.0296;Float;False;0;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1076.132,-95.07028;Float;False;2;2;0;FLOAT3;0.0;False;1;FLOAT;0.0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;51;-1009.087,-248.1262;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.ComponentMaskNode;55;-857.3359,-90.57038;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-626.9285,-216.5684;Float;True;2;2;0;FLOAT2;0.0,0;False;1;FLOAT2;0.0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;47;-403.7443,-359.0478;Float;True;Global;_GrabNoBlurTexture;_GrabNoBlurTexture;0;0;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;18;-392.608,-117.0344;Float;True;Global;_GrabBlurTexture;_GrabBlurTexture;1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;53;-400.3706,-590.7485;Float;True;Property;_AlbedoRGBBlurA;Albedo (RGB) Blur (A);2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;87;-375.1392,-798.0683;Half;False;Property;_ReflectionStrength;Reflection Strength;8;0;1;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;49;33.14941,-333.6691;Float;True;3;0;COLOR;0.0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;66;335.0458,-806.5895;Half;False;Property;_EmissionContribution;Emission Contribution;7;0;0.3;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;91;49.56155,-725.2689;Float;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.0;False;2;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;647.2706,-722.5212;Float;True;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT4;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;58;27.5927,-71.0429;Float;True;Property;_MetallicRSmoothnessGOcclusionBOpacityA;Metallic (R) Smoothness (G) Occlusion (B) Opacity (A);3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1094.398,-366.9636;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/RefractionWithCommandBuffer;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;False;False;Back;0;0;False;0;0;Translucent;0.5;True;True;0;False;Opaque;Transparent;ForwardOnly;True;True;True;False;False;False;True;False;False;False;False;False;False;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;5;63;0
WireConnection;56;0;52;0
WireConnection;56;1;57;0
WireConnection;51;0;46;0
WireConnection;55;0;56;0
WireConnection;54;0;51;0
WireConnection;54;1;55;0
WireConnection;47;1;54;0
WireConnection;18;1;54;0
WireConnection;49;0;47;0
WireConnection;49;1;18;0
WireConnection;49;2;53;4
WireConnection;91;0;53;0
WireConnection;91;1;49;0
WireConnection;91;2;87;0
WireConnection;65;0;66;0
WireConnection;65;1;91;0
WireConnection;0;0;91;0
WireConnection;0;1;52;0
WireConnection;0;2;65;0
WireConnection;0;3;58;1
WireConnection;0;4;58;2
WireConnection;0;5;58;3
WireConnection;0;9;58;4
ASEEND*/
//CHKSM=F7D175F5720514B358D75E6C1A645E32F5C8F03D