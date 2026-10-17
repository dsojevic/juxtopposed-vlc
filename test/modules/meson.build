vlc_tests += {
    'name': 'test_modules_visualization_resize',
    'sources': files('visualization/resize.c'),
    'suite': ['modules', 'test_modules'],
    'link_with': [libvlc, libvlccore],
    'module_depends': ['visual', 'demux_mock', 'araw', 'adummy'],
    'env': ['VLC_PLUGIN_PATH=' + vlc_build_root / 'modules'],
}

if opengl_dep.found() and (host_system == 'windows' or egl_dep.found())
    vlc_tests += {
        'name': 'test_modules_visualization_gl_resize',
        'sources': files('visualization/resize.c'),
        'suite': ['modules', 'test_modules'],
        'link_with': [libvlc, libvlccore],
        'c_args': ['-DVISUAL_RESIZE_TEST_GL'],
        'module_depends': vlc_plugins_targets.keys(),
        'env': ['VLC_PLUGIN_PATH=' + vlc_build_root / 'modules'],
    }
    vlc_tests += {
        'name': 'test_modules_visualization_projectm_resize',
        'sources': files('visualization/resize.c'),
        'suite': ['modules', 'test_modules'],
        'link_with': [libvlc, libvlccore],
        'c_args': ['-DVISUAL_RESIZE_TEST_GL', '-DVISUAL_RESIZE_TEST_PROJECTM'],
        'module_depends': vlc_plugins_targets.keys(),
        'enabled': get_option('projectm').allowed(),
        'env': ['VLC_PLUGIN_PATH=' + vlc_build_root / 'modules'],
    }
endif


vlc_tests += {
    'name' : 'test_modules_lua_extension',
    'sources' : files('lua/extension.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_lua_playlist_parser',
    'sources' : files('lua/playlist_parser.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : ['lua'],
}

vlc_tests += {
    'name': 'test_modules_misc_media_tracks',
    'sources': files('misc/media_tracks.c'),
    'suite': ['modules', 'test_modules'],
    'link_with': [libvlc, libvlccore],
    'module_depends': ['medialibrary', 'wav', 'araw', 'adummy', 'subtitle', 'subsdec'],
    'env': ['VLC_PLUGIN_PATH=' + vlc_build_root / 'modules'],
    'enabled': medialibrary_dep.found(),
}

if not (host_system == 'windows') # missing mkdtemp()
vlc_tests += {
    'name' : 'test_modules_misc_medialibrary',
    'sources' : files('misc/medialibrary.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys(),
    'enabled' : medialibrary_dep.found(),
    #'module_depends' : ['medialibrary', 'demux_mock', 'jpeg', 'png', 'rawvid'],
}
endif

vlc_tests += {
    'name' : 'test_modules_packetizer_helpers',
    'sources' : files('packetizer/helpers.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_hxxx',
    'sources' : files('packetizer/hxxx.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_h264',
    'sources' : files('packetizer/h264.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_hevc',
    'sources' : files('packetizer/hevc.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_h266',
    'sources' : files('packetizer/h266.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_h266_nal',
    'sources' : files(
        'packetizer/h266_nal.c',
        '../../modules/packetizer/h266_nal.c'
      ),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_packetizer_mpegvideo',
    'sources' : files('packetizer/mpegvideo.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_keystore',
    'sources' : files('keystore/test.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

if not(host_system == 'windows')
vlc_tests += {
    'name' : 'test_modules_tls',
    'sources' : files('misc/tls.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}
endif

vlc_tests += {
    'name' : 'test_modules_demux_json',
    'sources' : files('demux/json.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [vlc_json_lib, libvlccore],
}

vlc_tests += {
    'name' : 'test_modules_demux_libmp4',
    'sources' : files(
        'demux/libmp4.c',
        '../../modules/demux/mp4/libmp4.c'),
    'suite' : ['modules', 'test_modules'],
    'dependencies' : [z_dep],
    'link_with' : [libvlc, libvlccore],
}

vlc_tests += {
    'name' : 'test_modules_demux_timestamps',
    'sources' : files('demux/timestamps.c'),
    'suite' : ['modules', 'test_modules']
}

vlc_tests += {
    'name' : 'test_modules_demux_timestamps_filter',
    'sources' : files('demux/timestamps_filter.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_ts_pes',
    'sources' : files(
        'demux/ts_pes.c',
        '../../modules/demux/mpeg/ts_pes.c',
        '../../modules/demux/mpeg/ts_pes.h'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_codec_hxxx_helper',
    'sources' : files('codec/hxxx_helper.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore, hxxxhelper_lib],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_codec_cea708_aspect_ratio',
    'sources' : files('codec/cea708_aspect_ratio.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_codec_cea708_integration',
    'sources' : files('codec/cea708_integration.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_codec_cea708',
    'sources' : files('codec/cea708.c',
                      '../../modules/codec/cea708.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

if opengl_dep.found() and (host_system == 'windows' or egl_dep.found())
    foreach api, api_flag : {'opengl': 'VLC_OPENGL', 'opengl_es2': 'VLC_OPENGL_ES2'}
        if api == 'opengl' or host_system != 'windows'
            vlc_tests += {
                'name': 'test_modules_video_output_' + api + '_offscreen',
                'sources': files('video_output/opengl/offscreen.c'),
                'suite': ['modules', 'test_modules'],
                'link_with': [libvlc, libvlccore, libvlc_opengl],
                'dependencies': host_system == 'windows' ? [] : [egl_dep],
                'c_args': ['-DVLC_TEST_OPENGL_API=' + api_flag] + (host_system == 'windows' ? [] : ['-DVLC_TEST_EXTERNAL_EGL']),
                'module_depends': host_system == 'windows' ? ['opengl_win_offscreen'] : ['egl_pbuffer_filter', 'egl_display_generic'],
            }
        endif
    endforeach
endif

vlc_tests += {
    'name' : 'test_modules_video_output_opengl_filters',
    'sources' : files(
        'video_output/opengl/filters.c',
        '../../modules/video_output/opengl/filters.c',
        '../../modules/video_output/opengl/filters.h',
        '../../modules/video_output/opengl/filter.c',
        '../../modules/video_output/opengl/gl_api.c',
        '../../modules/video_output/opengl/gl_api.h',
        '../../modules/video_output/opengl/interop.c',
        '../../modules/video_output/opengl/interop.h',
        '../../modules/video_output/opengl/importer.c',
        '../../modules/video_output/opengl/importer.h'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore, libvlc_opengl],
    'c_args' : ['-DVLC_TEST_OPENGL_API=VLC_OPENGL'],
    'module_depends' : vlc_plugins_targets.keys(),
    'enabled' : opengl_dep.found(),
}

vlc_tests += {
    'name' : 'test_modules_video_output_opengl_es2_filters',
    'sources' : files(
        'video_output/opengl/filters.c',
        '../../modules/video_output/opengl/filters.c',
        '../../modules/video_output/opengl/filters.h',
        '../../modules/video_output/opengl/filter.c',
        '../../modules/video_output/opengl/gl_api.c',
        '../../modules/video_output/opengl/gl_api.h',
        '../../modules/video_output/opengl/interop.c',
        '../../modules/video_output/opengl/interop.h',
        '../../modules/video_output/opengl/importer.c',
        '../../modules/video_output/opengl/importer.h'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore, libvlc_opengles],
    'c_args' : ['-DVLC_TEST_OPENGL_API=VLC_OPENGL_ES2'],
    'module_depends' : vlc_plugins_targets.keys(),
    'enabled' : opengles2_dep.found(),
}

vlc_tests += {
    'name' : 'test_modules_stream_out_transcode',
    'sources' : files(
        'stream_out/transcode.c',
        'stream_out/transcode.h',
        'stream_out/transcode_scenarios.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_stream_out_sdi',
    'sources' : files(
        'stream_out/sdi.cpp',
        '../../modules/stream_out/sdi/SDIStream.cpp',
        '../../modules/stream_out/sdi/SDIStream.hpp'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore]
}

vlc_tests += {
    'name' : 'test_modules_stream_out_pcr_sync',
    'sources' : files(
        'stream_out/pcr_sync.c',
        '../../modules/stream_out/transcode/pcr_sync.c',
        '../../modules/stream_out/transcode/pcr_sync.h',
        '../../modules/stream_out/transcode/pcr_helper.c',
        '../../modules/stream_out/transcode/pcr_helper.h'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

vlc_tests += {
    'name' : 'test_modules_mux_webvtt',
    'sources' : files('mux/webvtt.c'),
    'suite' : ['modules', 'test_modules'],
    'link_with' : [libvlc, libvlccore],
    'module_depends' : vlc_plugins_targets.keys()
}

if pipewire_dep.found()
    vlc_tests += {
        'name': 'test_modules_audio_output_pipewire_devices',
        'sources': files('audio_output/pipewire_devices.c'),
        'suite': ['modules', 'test_modules'],
        'dependencies': [pipewire_dep, m_lib],
        'link_with': [libvlccore, libvlc_pipewire],
        'c_args': ['-ffunction-sections', '-fdata-sections'],
        'link_args': ['-Wl,--gc-sections'],
    }
endif

if have_wayland and egl_dep.found()
    foreach variant, variant_args : {
        'modern': [],
        'ext': ['-DTEST_EGL14'],
        'no_reference_headers': ['-DTEST_NO_REFERENCE_HEADERS'],
    }
        vlc_tests += {
            'name': 'test_modules_video_output_egl_display_' + variant,
            'sources': files('video_output/egl_display.c'),
            'suite': ['modules', 'test_modules'],
            'dependencies': [egl_dep, wayland_deps],
            'link_with': [libvlccore],
            'c_args': variant_args + ['-ffunction-sections', '-fdata-sections', '-Werror=incompatible-pointer-types'],
            'link_args': ['-Wl,--gc-sections'],
        }
    endforeach
endif
