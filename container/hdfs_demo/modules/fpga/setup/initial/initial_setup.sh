# Factory
sudo fpgasupdate \
    ${DEMO_ROOT}/fpga/FPGA_IMAGES/fim_pr_prebuilt/fim/ofs_top_page0_unsigned_factory.bin \
    0000:8a:00.0

# User 1
sudo fpgasupdate \
    ${DEMO_ROOT}/fpga/FPGA_IMAGES/fim_flat_sycl_rs_erasure_array_13x_RS_3_2/ofs_top_page1_unsigned_user1.bin \
    0000:8a:00.0
    
# User 2
sudo fpgasupdate \
    ${DEMO_ROOT}/fpga/FPGA_IMAGES/fim_flat_sycl_rs_erasure_array_6x_RS_6_3/ofs_top_page2_unsigned_user2.bin \
    0000:8a:00.0