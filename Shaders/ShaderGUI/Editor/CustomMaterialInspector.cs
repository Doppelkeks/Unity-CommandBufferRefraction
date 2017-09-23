/// <summary>
/// ---------
/// Shader GUI stub for Amplify Shader Editor shaders so we don't get a warning when copy & pasting shaders.
/// This is just laziness, so we don't have to remove the default shader GUI reference to "ASEMaterialInspector" made by Amplify.
/// ---------
/// </summary>

// Make sure to activate this class only if the AMPLIFY SHADER EDITOR isn't part of the project.
#if !AMPLIFY_SHADER_EDITOR
using UnityEngine;
using UnityEditor;

internal class ASEMaterialInspector : ShaderGUI{

	private static MaterialEditor m_instance = null;
	public override void OnGUI( MaterialEditor materialEditor, MaterialProperty[] properties ){
		Material mat = materialEditor.target as Material;

		if ( mat == null )
			return;

		m_instance = materialEditor;

		EditorGUI.BeginChangeCheck();
		base.OnGUI( materialEditor, properties );
		materialEditor.LightmapEmissionProperty();
		if ( EditorGUI.EndChangeCheck() )
		{
			string isEmissive = mat.GetTag( "IsEmissive", false, "false" );
			if ( isEmissive.Equals("true") )
			{
				mat.globalIlluminationFlags &= ( MaterialGlobalIlluminationFlags )3;
			}
			else
			{
				mat.globalIlluminationFlags |= MaterialGlobalIlluminationFlags.EmissiveIsBlack;
			}
		}
	}

	public static MaterialEditor Instance { get { return m_instance; } set { m_instance = value; } }
}
#endif
