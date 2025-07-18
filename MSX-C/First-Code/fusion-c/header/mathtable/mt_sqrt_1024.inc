//-----------------------------------------------------------------------------
// Math Table Generator (v1.4)                                               
// by Guillaume "Aoineko" Blanchard (aoineko@free.fr) under CC-BY-AS license 
// Generated: Sat Nov 14 20:35:37 2020
// Parameters: Entries=1024, Bytes=2 (16-bits), Shift=8 (Q8.8)               
//-----------------------------------------------------------------------------

// SquareRoot table. Range [0:N[
static const unsigned short g_SquareRoot1024[1024] =
{
	0x0000, 0x0100, 0x016A, 0x01BB, 0x0200, 0x023C, 0x0273, 0x02A5, 
	0x02D4, 0x0300, 0x0329, 0x0351, 0x0376, 0x039B, 0x03BD, 0x03DF, 
	0x0400, 0x041F, 0x043E, 0x045B, 0x0478, 0x0495, 0x04B0, 0x04CB, 
	0x04E6, 0x0500, 0x0519, 0x0532, 0x054A, 0x0562, 0x057A, 0x0591, 
	0x05A8, 0x05BE, 0x05D4, 0x05EA, 0x0600, 0x0615, 0x062A, 0x063E, 
	0x0653, 0x0667, 0x067B, 0x068E, 0x06A2, 0x06B5, 0x06C8, 0x06DB, 
	0x06ED, 0x0700, 0x0712, 0x0724, 0x0736, 0x0747, 0x0759, 0x076A, 
	0x077B, 0x078C, 0x079D, 0x07AE, 0x07BE, 0x07CF, 0x07DF, 0x07EF, 
	0x0800, 0x080F, 0x081F, 0x082F, 0x083F, 0x084E, 0x085D, 0x086D, 
	0x087C, 0x088B, 0x089A, 0x08A9, 0x08B7, 0x08C6, 0x08D4, 0x08E3, 
	0x08F1, 0x0900, 0x090E, 0x091C, 0x092A, 0x0938, 0x0946, 0x0953, 
	0x0961, 0x096F, 0x097C, 0x098A, 0x0997, 0x09A4, 0x09B2, 0x09BF, 
	0x09CC, 0x09D9, 0x09E6, 0x09F3, 0x0A00, 0x0A0C, 0x0A19, 0x0A26, 
	0x0A32, 0x0A3F, 0x0A4B, 0x0A58, 0x0A64, 0x0A70, 0x0A7C, 0x0A89, 
	0x0A95, 0x0AA1, 0x0AAD, 0x0AB9, 0x0AC5, 0x0AD1, 0x0ADC, 0x0AE8, 
	0x0AF4, 0x0B00, 0x0B0B, 0x0B17, 0x0B22, 0x0B2E, 0x0B39, 0x0B44, 
	0x0B50, 0x0B5B, 0x0B66, 0x0B72, 0x0B7D, 0x0B88, 0x0B93, 0x0B9E, 
	0x0BA9, 0x0BB4, 0x0BBF, 0x0BCA, 0x0BD5, 0x0BDF, 0x0BEA, 0x0BF5, 
	0x0C00, 0x0C0A, 0x0C15, 0x0C1F, 0x0C2A, 0x0C34, 0x0C3F, 0x0C49, 
	0x0C54, 0x0C5E, 0x0C68, 0x0C73, 0x0C7D, 0x0C87, 0x0C91, 0x0C9C, 
	0x0CA6, 0x0CB0, 0x0CBA, 0x0CC4, 0x0CCE, 0x0CD8, 0x0CE2, 0x0CEC, 
	0x0CF6, 0x0D00, 0x0D09, 0x0D13, 0x0D1D, 0x0D27, 0x0D30, 0x0D3A, 
	0x0D44, 0x0D4D, 0x0D57, 0x0D61, 0x0D6A, 0x0D74, 0x0D7D, 0x0D87, 
	0x0D90, 0x0D99, 0x0DA3, 0x0DAC, 0x0DB6, 0x0DBF, 0x0DC8, 0x0DD1, 
	0x0DDB, 0x0DE4, 0x0DED, 0x0DF6, 0x0E00, 0x0E09, 0x0E12, 0x0E1B, 
	0x0E24, 0x0E2D, 0x0E36, 0x0E3F, 0x0E48, 0x0E51, 0x0E5A, 0x0E63, 
	0x0E6C, 0x0E74, 0x0E7D, 0x0E86, 0x0E8F, 0x0E98, 0x0EA0, 0x0EA9, 
	0x0EB2, 0x0EBB, 0x0EC3, 0x0ECC, 0x0ED5, 0x0EDD, 0x0EE6, 0x0EEE, 
	0x0EF7, 0x0F00, 0x0F08, 0x0F11, 0x0F19, 0x0F21, 0x0F2A, 0x0F32, 
	0x0F3B, 0x0F43, 0x0F4C, 0x0F54, 0x0F5C, 0x0F65, 0x0F6D, 0x0F75, 
	0x0F7D, 0x0F86, 0x0F8E, 0x0F96, 0x0F9E, 0x0FA7, 0x0FAF, 0x0FB7, 
	0x0FBF, 0x0FC7, 0x0FCF, 0x0FD7, 0x0FDF, 0x0FE7, 0x0FEF, 0x0FF7, 
	0x1000, 0x1007, 0x100F, 0x1017, 0x101F, 0x1027, 0x102F, 0x1037, 
	0x103F, 0x1047, 0x104F, 0x1057, 0x105E, 0x1066, 0x106E, 0x1076, 
	0x107E, 0x1085, 0x108D, 0x1095, 0x109C, 0x10A4, 0x10AC, 0x10B4, 
	0x10BB, 0x10C3, 0x10CA, 0x10D2, 0x10DA, 0x10E1, 0x10E9, 0x10F0, 
	0x10F8, 0x1100, 0x1107, 0x110F, 0x1116, 0x111E, 0x1125, 0x112C, 
	0x1134, 0x113B, 0x1143, 0x114A, 0x1152, 0x1159, 0x1160, 0x1168, 
	0x116F, 0x1176, 0x117E, 0x1185, 0x118C, 0x1194, 0x119B, 0x11A2, 
	0x11A9, 0x11B1, 0x11B8, 0x11BF, 0x11C6, 0x11CD, 0x11D5, 0x11DC, 
	0x11E3, 0x11EA, 0x11F1, 0x11F8, 0x1200, 0x1207, 0x120E, 0x1215, 
	0x121C, 0x1223, 0x122A, 0x1231, 0x1238, 0x123F, 0x1246, 0x124D, 
	0x1254, 0x125B, 0x1262, 0x1269, 0x1270, 0x1277, 0x127E, 0x1285, 
	0x128C, 0x1292, 0x1299, 0x12A0, 0x12A7, 0x12AE, 0x12B5, 0x12BC, 
	0x12C2, 0x12C9, 0x12D0, 0x12D7, 0x12DE, 0x12E4, 0x12EB, 0x12F2, 
	0x12F9, 0x1300, 0x1306, 0x130D, 0x1314, 0x131A, 0x1321, 0x1328, 
	0x132E, 0x1335, 0x133C, 0x1342, 0x1349, 0x1350, 0x1356, 0x135D, 
	0x1364, 0x136A, 0x1371, 0x1377, 0x137E, 0x1384, 0x138B, 0x1392, 
	0x1398, 0x139F, 0x13A5, 0x13AC, 0x13B2, 0x13B9, 0x13BF, 0x13C6, 
	0x13CC, 0x13D3, 0x13D9, 0x13DF, 0x13E6, 0x13EC, 0x13F3, 0x13F9, 
	0x1400, 0x1406, 0x140C, 0x1413, 0x1419, 0x141F, 0x1426, 0x142C, 
	0x1432, 0x1439, 0x143F, 0x1445, 0x144C, 0x1452, 0x1458, 0x145F, 
	0x1465, 0x146B, 0x1471, 0x1478, 0x147E, 0x1484, 0x148A, 0x1491, 
	0x1497, 0x149D, 0x14A3, 0x14A9, 0x14B0, 0x14B6, 0x14BC, 0x14C2, 
	0x14C8, 0x14CF, 0x14D5, 0x14DB, 0x14E1, 0x14E7, 0x14ED, 0x14F3, 
	0x14F9, 0x1500, 0x1506, 0x150C, 0x1512, 0x1518, 0x151E, 0x1524, 
	0x152A, 0x1530, 0x1536, 0x153C, 0x1542, 0x1548, 0x154E, 0x1554, 
	0x155A, 0x1560, 0x1566, 0x156C, 0x1572, 0x1578, 0x157E, 0x1584, 
	0x158A, 0x1590, 0x1596, 0x159C, 0x15A2, 0x15A8, 0x15AD, 0x15B3, 
	0x15B9, 0x15BF, 0x15C5, 0x15CB, 0x15D1, 0x15D7, 0x15DC, 0x15E2, 
	0x15E8, 0x15EE, 0x15F4, 0x15FA, 0x1600, 0x1605, 0x160B, 0x1611, 
	0x1617, 0x161D, 0x1622, 0x1628, 0x162E, 0x1634, 0x1639, 0x163F, 
	0x1645, 0x164B, 0x1650, 0x1656, 0x165C, 0x1662, 0x1667, 0x166D, 
	0x1673, 0x1678, 0x167E, 0x1684, 0x1689, 0x168F, 0x1695, 0x169A, 
	0x16A0, 0x16A6, 0x16AB, 0x16B1, 0x16B7, 0x16BC, 0x16C2, 0x16C8, 
	0x16CD, 0x16D3, 0x16D8, 0x16DE, 0x16E4, 0x16E9, 0x16EF, 0x16F4, 
	0x16FA, 0x1700, 0x1705, 0x170B, 0x1710, 0x1716, 0x171B, 0x1721, 
	0x1726, 0x172C, 0x1731, 0x1737, 0x173C, 0x1742, 0x1747, 0x174D, 
	0x1752, 0x1758, 0x175D, 0x1763, 0x1768, 0x176E, 0x1773, 0x1779, 
	0x177E, 0x1784, 0x1789, 0x178E, 0x1794, 0x1799, 0x179F, 0x17A4, 
	0x17AA, 0x17AF, 0x17B4, 0x17BA, 0x17BF, 0x17C5, 0x17CA, 0x17CF, 
	0x17D5, 0x17DA, 0x17DF, 0x17E5, 0x17EA, 0x17EF, 0x17F5, 0x17FA, 
	0x1800, 0x1805, 0x180A, 0x180F, 0x1815, 0x181A, 0x181F, 0x1825, 
	0x182A, 0x182F, 0x1835, 0x183A, 0x183F, 0x1844, 0x184A, 0x184F, 
	0x1854, 0x185A, 0x185F, 0x1864, 0x1869, 0x186E, 0x1874, 0x1879, 
	0x187E, 0x1883, 0x1889, 0x188E, 0x1893, 0x1898, 0x189D, 0x18A3, 
	0x18A8, 0x18AD, 0x18B2, 0x18B7, 0x18BD, 0x18C2, 0x18C7, 0x18CC, 
	0x18D1, 0x18D6, 0x18DC, 0x18E1, 0x18E6, 0x18EB, 0x18F0, 0x18F5, 
	0x18FA, 0x1900, 0x1905, 0x190A, 0x190F, 0x1914, 0x1919, 0x191E, 
	0x1923, 0x1928, 0x192D, 0x1932, 0x1938, 0x193D, 0x1942, 0x1947, 
	0x194C, 0x1951, 0x1956, 0x195B, 0x1960, 0x1965, 0x196A, 0x196F, 
	0x1974, 0x1979, 0x197E, 0x1983, 0x1988, 0x198D, 0x1992, 0x1997, 
	0x199C, 0x19A1, 0x19A6, 0x19AB, 0x19B0, 0x19B5, 0x19BA, 0x19BF, 
	0x19C4, 0x19C9, 0x19CE, 0x19D3, 0x19D8, 0x19DD, 0x19E2, 0x19E7, 
	0x19EC, 0x19F1, 0x19F6, 0x19FB, 0x1A00, 0x1A04, 0x1A09, 0x1A0E, 
	0x1A13, 0x1A18, 0x1A1D, 0x1A22, 0x1A27, 0x1A2C, 0x1A31, 0x1A35, 
	0x1A3A, 0x1A3F, 0x1A44, 0x1A49, 0x1A4E, 0x1A53, 0x1A58, 0x1A5C, 
	0x1A61, 0x1A66, 0x1A6B, 0x1A70, 0x1A75, 0x1A79, 0x1A7E, 0x1A83, 
	0x1A88, 0x1A8D, 0x1A92, 0x1A96, 0x1A9B, 0x1AA0, 0x1AA5, 0x1AAA, 
	0x1AAE, 0x1AB3, 0x1AB8, 0x1ABD, 0x1AC2, 0x1AC6, 0x1ACB, 0x1AD0, 
	0x1AD5, 0x1AD9, 0x1ADE, 0x1AE3, 0x1AE8, 0x1AED, 0x1AF1, 0x1AF6, 
	0x1AFB, 0x1B00, 0x1B04, 0x1B09, 0x1B0E, 0x1B12, 0x1B17, 0x1B1C, 
	0x1B21, 0x1B25, 0x1B2A, 0x1B2F, 0x1B33, 0x1B38, 0x1B3D, 0x1B42, 
	0x1B46, 0x1B4B, 0x1B50, 0x1B54, 0x1B59, 0x1B5E, 0x1B62, 0x1B67, 
	0x1B6C, 0x1B70, 0x1B75, 0x1B7A, 0x1B7E, 0x1B83, 0x1B88, 0x1B8C, 
	0x1B91, 0x1B96, 0x1B9A, 0x1B9F, 0x1BA3, 0x1BA8, 0x1BAD, 0x1BB1, 
	0x1BB6, 0x1BBB, 0x1BBF, 0x1BC4, 0x1BC8, 0x1BCD, 0x1BD2, 0x1BD6, 
	0x1BDB, 0x1BDF, 0x1BE4, 0x1BE9, 0x1BED, 0x1BF2, 0x1BF6, 0x1BFB, 
	0x1C00, 0x1C04, 0x1C09, 0x1C0D, 0x1C12, 0x1C16, 0x1C1B, 0x1C1F, 
	0x1C24, 0x1C29, 0x1C2D, 0x1C32, 0x1C36, 0x1C3B, 0x1C3F, 0x1C44, 
	0x1C48, 0x1C4D, 0x1C51, 0x1C56, 0x1C5A, 0x1C5F, 0x1C63, 0x1C68, 
	0x1C6C, 0x1C71, 0x1C75, 0x1C7A, 0x1C7E, 0x1C83, 0x1C87, 0x1C8C, 
	0x1C90, 0x1C95, 0x1C99, 0x1C9E, 0x1CA2, 0x1CA7, 0x1CAB, 0x1CB0, 
	0x1CB4, 0x1CB9, 0x1CBD, 0x1CC1, 0x1CC6, 0x1CCA, 0x1CCF, 0x1CD3, 
	0x1CD8, 0x1CDC, 0x1CE1, 0x1CE5, 0x1CE9, 0x1CEE, 0x1CF2, 0x1CF7, 
	0x1CFB, 0x1D00, 0x1D04, 0x1D08, 0x1D0D, 0x1D11, 0x1D16, 0x1D1A, 
	0x1D1E, 0x1D23, 0x1D27, 0x1D2C, 0x1D30, 0x1D34, 0x1D39, 0x1D3D, 
	0x1D41, 0x1D46, 0x1D4A, 0x1D4F, 0x1D53, 0x1D57, 0x1D5C, 0x1D60, 
	0x1D64, 0x1D69, 0x1D6D, 0x1D71, 0x1D76, 0x1D7A, 0x1D7E, 0x1D83, 
	0x1D87, 0x1D8B, 0x1D90, 0x1D94, 0x1D98, 0x1D9D, 0x1DA1, 0x1DA5, 
	0x1DAA, 0x1DAE, 0x1DB2, 0x1DB7, 0x1DBB, 0x1DBF, 0x1DC4, 0x1DC8, 
	0x1DCC, 0x1DD0, 0x1DD5, 0x1DD9, 0x1DDD, 0x1DE2, 0x1DE6, 0x1DEA, 
	0x1DEE, 0x1DF3, 0x1DF7, 0x1DFB, 0x1E00, 0x1E04, 0x1E08, 0x1E0C, 
	0x1E11, 0x1E15, 0x1E19, 0x1E1D, 0x1E22, 0x1E26, 0x1E2A, 0x1E2E, 
	0x1E33, 0x1E37, 0x1E3B, 0x1E3F, 0x1E43, 0x1E48, 0x1E4C, 0x1E50, 
	0x1E54, 0x1E59, 0x1E5D, 0x1E61, 0x1E65, 0x1E69, 0x1E6E, 0x1E72, 
	0x1E76, 0x1E7A, 0x1E7E, 0x1E83, 0x1E87, 0x1E8B, 0x1E8F, 0x1E93, 
	0x1E98, 0x1E9C, 0x1EA0, 0x1EA4, 0x1EA8, 0x1EAC, 0x1EB1, 0x1EB5, 
	0x1EB9, 0x1EBD, 0x1EC1, 0x1EC5, 0x1ECA, 0x1ECE, 0x1ED2, 0x1ED6, 
	0x1EDA, 0x1EDE, 0x1EE3, 0x1EE7, 0x1EEB, 0x1EEF, 0x1EF3, 0x1EF7, 
	0x1EFB, 0x1F00, 0x1F04, 0x1F08, 0x1F0C, 0x1F10, 0x1F14, 0x1F18, 
	0x1F1C, 0x1F20, 0x1F25, 0x1F29, 0x1F2D, 0x1F31, 0x1F35, 0x1F39, 
	0x1F3D, 0x1F41, 0x1F45, 0x1F49, 0x1F4E, 0x1F52, 0x1F56, 0x1F5A, 
	0x1F5E, 0x1F62, 0x1F66, 0x1F6A, 0x1F6E, 0x1F72, 0x1F76, 0x1F7A, 
	0x1F7E, 0x1F83, 0x1F87, 0x1F8B, 0x1F8F, 0x1F93, 0x1F97, 0x1F9B, 
	0x1F9F, 0x1FA3, 0x1FA7, 0x1FAB, 0x1FAF, 0x1FB3, 0x1FB7, 0x1FBB, 
	0x1FBF, 0x1FC3, 0x1FC7, 0x1FCB, 0x1FCF, 0x1FD3, 0x1FD7, 0x1FDB, 
	0x1FDF, 0x1FE3, 0x1FE7, 0x1FEB, 0x1FEF, 0x1FF3, 0x1FF7, 0x1FFB, 
};
